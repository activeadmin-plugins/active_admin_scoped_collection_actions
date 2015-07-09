module ActiveAdminScopedCollectionActions
  module DSL

    def scoped_collection_action(name, options = {}, &block)
      # controller
      if name == :batch_destroy
        add_scoped_collection_action_default_destroy(name, options, &block)
      elsif name == :batch_update
        add_scoped_collection_action_default_update(name, options, &block)
      else
        batch_action(name, if: proc { false }, &block)
      end
      # sidebar button
      config.add_scoped_collection_action(name, options)
    end

    def add_scoped_collection_action_default_update(options, &block)
      batch_action :scoped_collection_update, if: proc { false } do |selection, _|
        collection = selection.any? ? resource_class.where(id: selection) : batch_action_collection
        unless authorized?(:batch_edit, resource_class)
          flash[:error] = 'Access denied'
          render nothing: true, status: :no_content and next
        end
        if !params.has_key?(:changes) || params[:changes].empty?
          render nothing: true, status: :no_content and next
        end
        permitted_changes = params.require(:changes).permit(*(options[:form].call.keys))
        errors = []
        if block_given?
          instance_eval &block
        else
          collection.find_each do |record|
            errors << "#{record.id} | #{record.errors.full_messages.join('. ')}" unless update_resource(record, [permitted_changes])
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

    def add_scoped_collection_action_default_destroy(_, &block)
      batch_action :scoped_collection_destroy, if: proc { false } do |selection|
        collection = selection.any? ? resource_class.where(id: selection) : batch_action_collection
        unless authorized?(:batch_destroy, resource_class)
          flash[:error] = 'Access denied'
          render nothing: true, status: :no_content and next
        end
        errors = []
        if block_given?
          instance_eval &block
        else
          collection.find_each do |record|
            errors << "#{record.id} | Cant be destroyed}" unless destroy_resource(record)
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
