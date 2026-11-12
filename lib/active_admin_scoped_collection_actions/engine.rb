module ActiveAdminScopedCollectionActions
  module Rails
    class Engine < ::Rails::Engine
      config.after_initialize do
        ActiveAdmin::ResourceController.send :include, ActiveAdminScopedCollectionActions::Controller
      end

      # ActiveAdmin 4 renders its own import map, ActiveAdmin.importmap, so the
      # dialog module is pinned there rather than in the host's importmap.
      initializer 'active_admin_scoped_collection_actions.importmap', after: 'active_admin.importmap' do |app|
        next unless ActiveAdmin.respond_to?(:importmap) && app.config.respond_to?(:importmap)

        ActiveAdmin.importmap.draw(root.join('config', 'importmap.rb'))
        app.config.assets.paths << root.join('app/javascript') if app.config.respond_to?(:assets)
        if ActiveAdmin.application.respond_to?(:importmap_watches)
          ActiveAdmin.application.importmap_watches << root.join('app/javascript')
        end
      end

      # javascript_modules is pending upstream (activeadmin/activeadmin#9148).
      # Without it the host imports the module itself, see the README.
      config.after_initialize do
        if ActiveAdmin.application.respond_to?(:javascript_modules)
          ActiveAdmin.application.javascript_modules |= %w[active_admin_scoped_collection_actions]
        end
      end
    end
  end
end
