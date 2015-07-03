require 'rails'

module ActiveAdminScopedCollectionActions
  class Engine < ::Rails::Engine
    config.mount_at = '/'
  end
end
