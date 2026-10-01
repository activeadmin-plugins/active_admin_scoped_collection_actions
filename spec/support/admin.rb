def add_author_resource(options = {}, &block)

  ActiveAdmin.register Author do
    config.filters = true
    decorate_with AuthorDecorator

    config.scoped_collection_actions_if = -> { true }

    scoped_collection_action :scoped_collection_update,
                             title: 'Update',
                             form: -> {
                               {birthday: 'datepicker',
                                last_name: {type: 'text', class: 'my-widget'}}
                             }
    scoped_collection_action :scoped_collection_destroy,
                             title: 'Delete',
                             confirm: 'Delete all?',
                             confirm_summary: true
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


# Author under its own resource name. ActiveAdmin reuses an already registered
# Resource object and never clears its scoped_collection_actions hash, so a
# resource whose options change from example to example needs a name of its own
# or it leaks into the authors resource.
# Routed as /admin/option_authors.
def add_option_author_resource(update: {}, destroy: {}, custom: {})

  ActiveAdmin.register Author, as: 'OptionAuthor' do
    config.filters = true

    config.scoped_collection_actions_if = -> { true }

    scoped_collection_action :scoped_collection_update,
                             { title: 'Update',
                               confirm: 'Fill the form',
                               form: -> { {last_name: 'text'} } }.merge(update)
    scoped_collection_action :scoped_collection_destroy,
                             { title: 'Delete',
                               confirm: 'Delete all?',
                               confirm_summary: true }.merge(destroy)
    scoped_collection_action :scoped_collection_custom_action,
                             { title: 'Act',
                               confirm: 'Act on all?' }.merge(custom) do
                               flash[:notice] = 'Action executed'
                             end
  end

  Rails.application.reload_routes!

end


# Author whose scoped_collection is grouped, so the relation yields one row per
# group rather than one per record. A bare .count on it answers with a Hash of
# per-group tallies, which is why the count action goes through a subquery.
# Routed as /admin/grouped_authors.
def add_grouped_author_resource

  ActiveAdmin.register Author, as: 'GroupedAuthor' do
    config.filters = true

    config.scoped_collection_actions_if = -> { true }

    controller do
      def scoped_collection
        end_of_association_chain.group(:birthday)
      end
    end

    scoped_collection_action :scoped_collection_destroy,
                             title: 'Delete',
                             confirm: 'Delete all?',
                             confirm_summary: true
  end

  Rails.application.reload_routes!
end

# Author whose scoped_collection already carries order and limit. The count
# action drops the order, which cannot change how many rows there are, and
# keeps the limit, which can -- find_each honours it.
# Routed as /admin/ordered_authors.
def add_ordered_author_resource

  ActiveAdmin.register Author, as: 'OrderedAuthor' do
    config.filters = true

    config.scoped_collection_actions_if = -> { true }

    controller do
      def scoped_collection
        end_of_association_chain.order(:name).limit(1)
      end
    end

    scoped_collection_action :scoped_collection_destroy,
                             title: 'Delete',
                             confirm: 'Delete all?',
                             confirm_summary: true
  end

  Rails.application.reload_routes!

end


def add_post_resource(options = {}, &block)

  ActiveAdmin.register Post do
    config.filters = true

    config.scoped_collection_actions_if = -> { true }

    scoped_collection_action :scoped_collection_update,
                             title: 'Update',
                             confirm_submit: 'Apply changes to all posts?',
                             form: -> {
                               {
                                   body: 'text',
                                   author_id: Author.all.map { |author| [author.name, author.id] }
                               }
                             }
    scoped_collection_action :scoped_collection_destroy,
                             title: 'Delete',
                             confirm: -> { 'Custom text for confirm delete all?' }
  end

  Rails.application.reload_routes!

end
