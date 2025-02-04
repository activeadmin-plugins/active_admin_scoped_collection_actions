def add_author_resource(options = {}, &block)

  ActiveAdmin.register Author do
    config.filters = true
    decorate_with AuthorDecorator

    config.scoped_collection_actions_if = -> { true }

    scoped_collection_action :scoped_collection_update,
                             title: 'Update',
                             form: -> {
                               {birthday: 'datepicker'}
                             }
    scoped_collection_action :scoped_collection_destroy,
                             title: 'Delete',
                             confirm: 'Delete all?'
    scoped_collection_action :scoped_collection_custom_visible,
                             if: proc { true },
                             title: 'Visible Action' do
                               flash[:notice] = 'Visible action executed'
                             end
    scoped_collection_action :scoped_collection_custom_hidden,
                             if: proc { false },
                             title: 'Hidden Action'
                             
  end

  Rails.application.reload_routes!

end


def add_post_resource(options = {}, &block)

  ActiveAdmin.register Post do
    config.filters = true

    config.scoped_collection_actions_if = -> { true }

    scoped_collection_action :scoped_collection_update,
                             title: 'Update',
                             form: -> {
                               {
                                   body: 'text',
                                   author_id: Author.all.map { |author| [author.name, author.id] }
                               }
                             }
  end

  Rails.application.reload_routes!

end
