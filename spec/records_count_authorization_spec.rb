require 'spec_helper'

# The :scoped_collection_records_count batch action has no authorized? guard,
# unlike :scoped_collection_update and :scoped_collection_destroy. Its comment
# claims that is safe because "Collection is already limited by authorization
# scope". These specs pin down both halves of that claim: the scope really is
# applied to the count, and the count is served anyway to a user who is not
# allowed to run the action.
describe 'affected records count under authorization', type: :feature, js: true do

  # Hides everybody but John from the collection, the way CanCan's
  # accessible_by would.
  class AuthorizationScopedToJohn < ActiveAdmin::AuthorizationAdapter
    def scope_collection(collection, _action = ActiveAdmin::Auth::READ)
      collection.where(name: 'John')
    end
  end

  # May look at the index page, may not run the batch action.
  class AuthorizationWithoutBatchDestroy < ActiveAdmin::AuthorizationAdapter
    def authorized?(action, subject = nil)
      action != ActiveAdminScopedCollectionActions::Auth::BATCH_DESTROY
    end
  end

  let(:namespace) { ActiveAdmin.application.namespaces[:admin] }

  before do
    Author.create!(name: 'John', last_name: 'Doe')
    Author.create!(name: 'Jane', last_name: 'Roe')
    Author.create!(name: 'Jack', last_name: 'Poe')
  end

  before do
    add_option_author_resource
    namespace.authorization_adapter = adapter
    visit '/admin/option_authors'
  end

  after do
    namespace.authorization_adapter = ActiveAdmin::AuthorizationAdapter
  end

  context 'when the adapter narrows the collection' do
    let(:adapter) { AuthorizationScopedToJohn }

    it 'counts the records inside the authorization scope only' do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 1 record(s).')
      expect(Author.count).to eq(3)
    end
  end

  context 'when the user is not authorized for the action' do
    let(:adapter) { AuthorizationWithoutBatchDestroy }

    it 'tells them how many records the collection holds' do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 3 record(s).')
    end

    it 'refuses the action itself' do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('button', text: 'OK').click
      end
      # Not asserting the wording: no_permissions_msg is looked up under
      # .actions. while en.yml keeps it at the top level, so the flash is
      # currently a "Translation missing" sentence. Predates this branch.
      expect(page).to have_css('.flashes .flash.flash_error')
      expect(Author.count).to eq(3)
    end
  end
end
