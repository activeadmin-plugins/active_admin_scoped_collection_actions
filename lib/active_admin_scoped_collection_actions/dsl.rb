module ActiveAdminScopedCollectionActions
  module DSL

    def scoped_collection_action(name, options = {}, &block)
      if name == :scoped_collection_destroy
        options[:title] = 'Delete batch' if options[:title].nil?
        add_scoped_collection_action_default_destroy(options, &block)
      elsif name == :scoped_collection_update
        options[:title] = 'Update batch' if options[:title].nil?
        add_scoped_collection_action_default_update(options, &block)
      else
        batch_action(name, if: proc { false }, &block)
      end
      # sidebar button
      config.add_scoped_collection_action(name, options)
    end


    def add_scoped_collection_action_default_update(options, &block)
      batch_action :scoped_collection_update, if: proc { false } do
        unless authorized?(:batch_edit, resource_class)
          flash[:error] = 'Access denied'
          render nothing: true, status: :no_content and next
        end
        if !params.has_key?(:changes) || params[:changes].empty?
          render nothing: true, status: :no_content and next
        end
        permitted_changes = params.require(:changes).permit(*(options[:form].call.keys))
        if block_given?
          instance_eval &block
        else
          errors = []
          scoped_collection_records.find_each do |record|
            unless update_resource(record, [permitted_changes])
              errors << "#{record.attributes[resource_class.primary_key]} | #{record.errors.full_messages.join('. ')}"
            end
          end
          if errors.empty?
            flash[:notice] = 'Batch update done'
          else
            flash[:error] = errors.join(". ")
          end
          render nothing: true, status: :no_content
        end
      end
    end


    def add_scoped_collection_action_default_destroy(_, &block)
      batch_action :scoped_collection_destroy, if: proc { false } do |_|
        unless authorized?(:batch_destroy, resource_class)
          flash[:error] = 'Access denied'
          render nothing: true, status: :no_content and next
        end
        if block_given?
          instance_eval &block
        else
          errors = []
          scoped_collection_records.find_each do |record|
            unless destroy_resource(record)
              errors << "#{record.attributes[resource_class.primary_key]} | Cant be destroyed}"
            end
          end
          if errors.empty?
            flash[:notice] = 'Batch destroy done'
          else
            flash[:error] = errors.join(". ")
          end
          render nothing: true, status: :no_content
        end
      end
    end


  end
end
