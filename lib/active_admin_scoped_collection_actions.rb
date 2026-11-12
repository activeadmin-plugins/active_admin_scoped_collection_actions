require 'activeadmin'

module ActiveAdminScopedCollectionActions
  # ActiveAdmin 4 replaced jQuery UI and Sprockets with Flowbite, Tailwind and
  # importmaps, so the sidebar markup and the dialog script differ per version.
  def self.aa_v4?
    Gem::Version.new(ActiveAdmin::VERSION) >= Gem::Version.new('4.0.0.beta1')
  end
end

require 'active_admin_scoped_collection_actions/engine'
require 'active_admin_scoped_collection_actions/version'
require 'active_admin_scoped_collection_actions/dsl'
require 'active_admin_scoped_collection_actions/resource_extension'
require 'active_admin_scoped_collection_actions/controller'
require 'active_admin_scoped_collection_actions/authorization'

ActiveAdmin::ResourceDSL.send :include, ActiveAdminScopedCollectionActions::DSL
ActiveAdmin::Resource.send :include, ActiveAdminScopedCollectionActions::ResourceExtension
ActiveAdmin::Authorization.send :include, ActiveAdminScopedCollectionActions::Authorization
