module ActiveAdminScopedCollectionActions
  module Controller
    def scoped_collection_records
      selection = params.fetch(:collection_selection, [])
      selection.any? ? batch_action_collection.where(resource_class.primary_key => selection) : batch_action_collection
    end
  end
end
