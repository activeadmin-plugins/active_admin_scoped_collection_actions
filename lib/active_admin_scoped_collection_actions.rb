require 'active_admin'
require 'active_admin_scoped_collection_actions/version'
require 'active_admin_scoped_collection_actions/engine'
require 'active_admin_scoped_collection_actions/dsl'
require 'active_admin_scoped_collection_actions/resource_extension'
require 'active_admin_scoped_collection_actions/authorization'

ActiveAdmin::ResourceDSL.send :include, ActiveAdminScopedCollectionActions::DSL
ActiveAdmin::Resource.send    :include, ActiveAdminScopedCollectionActions::ResourceExtension