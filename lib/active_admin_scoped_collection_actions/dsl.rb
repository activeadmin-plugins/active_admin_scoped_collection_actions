module ActiveAdminScopedCollectionActions
  module DSL

    def filtered_actions(options)

      sidebar 'Batch operations',
              only: [:index],
              if: proc {
                active_admin_config.batch_actions.any? &&
                    (params[:q] || params[:scope]) &&
                    (authorized?(:batch_edit, resource_class) || authorized?(:batch_destroy, resource_class))
              }, class: 'sidebar_batch_actions_by_filters' do

        para 'This batch operations affect selected records. Or if none is selected, it will involve all records by current filters and scopes.'

        button 'Edit', { class: :show_form_mass_fields_update,
                         data: { inputs: options[:inputs].call,
                                 auth_token: form_authenticity_token.to_s }.to_json }
        button 'Delete', { class: :aa_scoped_collection_destroy,
                           data: { auth_token: form_authenticity_token.to_s }.to_json }
      end


      batch_action :batch_update, if: proc { false } do |selection, _|
        collection = selection.any? ? resource_class.where(id: selection) : batch_action_collection
        unless authorized?(:batch_edit, resource_class)
          redirect_to(:back, flash: {error: 'Access denied'}) and next
        end
        if !params.has_key?(:changes) || params[:changes].empty?
          redirect_to :back and next
        end
        permitted_changes = params.require(:changes).permit( *(options[:inputs].call.keys) )
        errors = []
        collection.find_in_batches do |group|
          group.each do |record|
            res = update_resource(record, [permitted_changes])
            errors << "#{record.id} | #{record.errors.full_messages.join('. ')}" unless res
          end
        end
        if errors.empty?
          flash[:notice] = 'Batch update done'
        else
          flash[:error] = errors.join(". ")
        end
        redirect_to :back
      end


      batch_action :batch_destroy, if: proc { false } do |selection, _|
        collection = selection.any? ? resource_class.where(id: selection) : batch_action_collection
        unless authorized?(:batch_destroy, resource_class)
          redirect_to(:back, flash: {error: 'Access denied'}) and next
        end
        errors = []
        collection.find_in_batches do |group|
          group.each do |record|
            res = destroy_resource(record)
            errors << "#{record.id} | Cant be destroyed}" unless res
          end
        end
        if errors.empty?
          flash[:notice] = 'Batch destroy done'
        else
          flash[:error] = errors.join(". ")
        end

        redirect_to :back
      end

    end

  end
end
