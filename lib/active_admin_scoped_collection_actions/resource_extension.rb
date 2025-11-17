module ActiveAdminScopedCollectionActions
  module ResourceExtension
    include MethodOrProcHelper

    def initialize(*)
      super
      add_scoped_collection_actions_sidebar_section
    end

    def scoped_collection_actions
      @scoped_collection_actions || {}
    end

    def scoped_collection_actions_on_all=(bool)
      @scoped_collection_actions_unconditionally = bool
    end

    def scoped_collection_actions_on_all
      @scoped_collection_actions_unconditionally || false
    end

    def add_scoped_collection_action(name, options)
      (@scoped_collection_actions ||= {})[name.to_sym] = options
    end

    def add_scoped_collection_actions_sidebar_section
      self.sidebar_sections << scoped_collection_actions_sidebar_section
    end

    def scoped_collection_actions_if=(if_proc)
      @if_proc = if_proc
    end

    def scoped_collection_actions_if
      @if_proc
    end

    def scoped_collection_sidebar_condition
      -> do
        if active_admin_config.scoped_collection_actions_if.is_a?(Proc)
          instance_exec &active_admin_config.scoped_collection_actions_if
        else
          filtered_scoped = (params[:q] || params[:scope])
          on_all = active_admin_config.scoped_collection_actions_on_all
          has_actions = active_admin_config.scoped_collection_actions.any?
          batch_actions_enabled = active_admin_config.batch_actions_enabled?
          ( batch_actions_enabled && has_actions && (filtered_scoped || on_all) )
        end
      end
    end

    def scoped_collection_actions_sidebar_section
      ActiveAdmin::SidebarSection.new :collection_actions, only: :index, if: scoped_collection_sidebar_condition do

        div I18n.t('active_admin_scoped_collection_actions.sidebar_msg')

        active_admin_config.scoped_collection_actions.each do |key, options={}|
          next if options.key?(:if) && !call_method_or_exec_proc(options[:if])

          b_title = options.fetch(:title, ::ActiveSupport::Inflector.humanize(key))
          b_options = {}
          b_options[:class] = options[:class] if options[:class].present?
          # Important: If user did not specify html_class, then use default
          b_options[:class] = 'scoped_collection_action_button' unless b_options[:class]
          b_data = { auth_token: form_authenticity_token.to_s }
          b_data[:batch_action] = key.to_s
          if options[:form].present?
            b_data[:inputs] = options[:form].is_a?(Proc) ? options[:form].call : options[:form]
          end
          b_data[:confirm] = options.fetch(:confirm, I18n.t('active_admin_scoped_collection_actions.confirm_action_message'))
          b_data[:confirm] = b_data[:confirm].call if b_data[:confirm].is_a?(Proc)
          b_options[:data] = b_data.to_json
          button b_title, b_options
        end
      end
    end

  end
end
