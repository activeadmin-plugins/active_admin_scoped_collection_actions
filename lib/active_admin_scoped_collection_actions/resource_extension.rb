module ActiveAdminScopedCollectionActions
  module ResourceExtension

    def initialize(*)
      super
      add_scoped_collection_actions_sidebar_section
    end

    def scoped_collection_actions
      @scoped_collection_actions || {}
    end

    def add_scoped_collection_action(name, options)
      (@scoped_collection_actions ||= {})[name.to_sym] = options
    end

    def add_scoped_collection_actions_sidebar_section
      self.sidebar_sections << scoped_collection_actions_sidebar_section
    end

    def scoped_collection_actions_sidebar_section
      condition = -> do
        (params[:q] || params[:scope]) && active_admin_config.scoped_collection_actions.any?
      end
      ActiveAdmin::SidebarSection.new :collection_actions, only: :index, if: condition do
        # TODO: I18n.t('active_admin.scoped_collection_actions.info_msg')

        div 'This batch operations affect selected records. Or if none is selected, it will involve all records by current filters and scopes.'

        active_admin_config.scoped_collection_actions.each do |key, options={}|
          b_title = options.fetch(:title, ::ActiveSupport::Inflector.humanize(key))
          b_options = {}
          b_options[:class] = options[:class] if options[:class].present?
          # Important: If user did not specify no html_class, then use default
          b_options[:class] = 'scoped_collection_action_button' unless b_options[:class]
          b_data = { auth_token: form_authenticity_token.to_s }
          b_data[:batch_action] = key.to_s
          if options[:form].present?
            b_data[:inputs] = options[:form].is_a?(Proc) ? options[:form].call : options[:form]
          end
          b_data[:confirm] = options.fetch(:confirm, 'Are you sure?')
          b_options[:data] = b_data.to_json
          button b_title, b_options
        end
      end
    end

  end
end
