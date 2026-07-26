module ActiveAdminScopedCollectionActions
  module DSL

    def scoped_collection_action(name, options = {}, &block)
      add_scoped_collection_records_count_action
      if name == :scoped_collection_destroy
        options[:title] = I18n.t('active_admin_scoped_collection_actions.actions.delete') if options[:title].nil?
        add_scoped_collection_action_default_destroy(options, &block)
      elsif name == :scoped_collection_update
        options[:title] = I18n.t('active_admin_scoped_collection_actions.actions.update') if options[:title].nil?
        add_scoped_collection_action_default_update(options, &block)
      else
        batch_action(name, if: proc { false }, &block)
      end
      # sidebar button
      config.add_scoped_collection_action(name, options)
    end

    # Amount of records affected by a scoped collection action. Used by the confirmation
    # dialog of an action with :confirm_submit option. Collection is already limited by
    # authorization scope, so it exposes nothing the user can not see on the index page.
    def add_scoped_collection_records_count_action
      batch_action :scoped_collection_records_count, if: proc { false } do
        count = scoped_collection_records.except(:eager_load, :select, :order, :limit, :offset).count
        render json: { count: count }
      end
    end

    def add_scoped_collection_action_default_update(options, &block)
      batch_action :scoped_collection_update, if: proc { false } do
        unless authorized?(:batch_edit, resource_class)
          flash[:error] = I18n.t('active_admin_scoped_collection_actions.actions.no_permissions_msg')
          head :ok and next
        end
        if !params.has_key?(:changes) || params[:changes].empty?
          head :ok and next
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
            flash[:notice] = I18n.t('active_admin_scoped_collection_actions.batch_update_status_msg')
          else
            flash[:error] = errors.join(". ")
          end
          head :ok
        end
      end
    end

    def add_scoped_collection_action_default_destroy(_, &block)
      batch_action :scoped_collection_destroy, if: proc { false } do |_|
        unless authorized?(:batch_destroy, resource_class)
          flash[:error] = I18n.t('active_admin_scoped_collection_actions.actions.no_permissions_msg')
          head :ok and next
        end
        if block_given?
          instance_eval &block
        else
          errors = []
          scoped_collection_records.find_each do |record|
            unless destroy_resource(record)
              errors << "#{record.attributes[resource_class.primary_key]} | #{I18n.t('active_admin_scoped_collection_actions.fail_on_destroy_msg')}"
            end
          end
          if errors.empty?
            flash[:notice] = I18n.t('active_admin_scoped_collection_actions.batch_destroy_status_msg')
          else
            flash[:error] = errors.join(". ")
          end
          head :ok
        end
      end
    end

  end
end

