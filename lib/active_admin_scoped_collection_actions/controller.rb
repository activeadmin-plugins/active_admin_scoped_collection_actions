module ActiveAdminScopedCollectionActions
  module Controller
    COLLECTION_APPLIES = [
      :authorization_scope,
      :filtering,
      :scoping,
      :includes,
    ].freeze

    def scoped_collection_records
      selection = params.fetch(:collection_selection, [])
      selection.any? ? batch_action_collection(COLLECTION_APPLIES).where(resource_class.primary_key => selection)
        : batch_action_collection
    end
  end
end
