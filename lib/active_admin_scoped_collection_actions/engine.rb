module ActiveAdminScopedCollectionActions
  module Rails
    class Engine < ::Rails::Engine
      config.after_initialize do
        ActiveAdmin::ResourceController.send :include, ActiveAdminScopedCollectionActions::Controller
      end
    end
  end
end