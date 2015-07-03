require 'active_admin'
require 'active_admin_scoped_collection_actions/version'
require 'active_admin_scoped_collection_actions/engine'
require 'active_admin_scoped_collection_actions/dsl'
require 'active_admin_scoped_collection_actions/authorization'

::ActiveAdmin::DSL.send(:include, ActiveAdminScopedCollectionActions::DSL)
