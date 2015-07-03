require "activeadmin_scoped_collection_actions/version"

module ActiveAdminScopedCollectionActions

  def filtered_actions(options)

    sidebar 'Batch operations',
            only: [:index],
            if: proc {
              active_admin_config.batch_actions.any? &&
                  (params[:q] || params[:scope]) &&
                  (authorized?(:batch_edit, resource_class) || authorized?(:batch_destroy, resource_class))
            }, class: 'sidebar_batch_actions_by_filters' do

      para 'This batch operations affect all records involved by current filters and scopes'

      button 'Edit', {
                       class: :show_form_mass_fields_update,
                       data: {
                           inputs: options[:inputs].call,
                           auth_token: form_authenticity_token.to_s
                       }.to_json
                   }

      button_to 'Delete',
                { action: 'batch_action', q: params[:q], scope: params[:scope] },
                { params: { batch_action: 'batch_destroy' },
                  method: :post,
                  data: { confirm: 'Are you sure?', disable_with: 'Loading...' } }
    end


    batch_action :batch_update, if: proc { false } do
      unless authorized?(:batch_edit, resource_class)
        redirect_to(:back, flash: {error: 'Access denied'}) and next
      end
      if !params.has_key?(:changes) || params[:changes].empty?
        redirect_to :back and next
      end
      permitted_changes = params.require(:changes).permit( *(options[:inputs].call.keys) )
      errors = []
      batch_action_collection.each do |record|
        res = update_resource(record, [permitted_changes])
        errors << "#{record.id} | #{record.errors.full_messages.join('. ')}" unless res
      end
      if errors.empty?
        flash[:notice] = 'Batch update done'
      else
        flash[:error] = errors.join(". ")
      end
      redirect_to :back
    end


    batch_action :batch_destroy, if: proc { false } do
      unless authorized?(:batch_destroy, resource_class)
        redirect_to(:back, flash: {error: 'Access denied'}) and next
      end

      errors = []
      batch_action_collection.each do |record|
        res = destroy_resource(record)
        errors << "#{record.id} | Cant be destroyed}" unless res
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


ActiveAdmin::ResourceDSL.send :include, ActiveAdminScopedCollectionActions