require 'spec_helper'

# The sidebar promises the action affects the checked records, or everything the
# current filters and scopes match when nothing is checked. These specs pin the
# number the confirmation dialog shows against that promise.
describe 'affected records count', type: :feature, js: true do

  before do
    Author.create!(name: 'John', last_name: 'Doe')
    Author.create!(name: 'Jane', last_name: 'Roe')
    Author.create!(name: 'Jack', last_name: 'Poe')
  end

  context 'with a filter applied' do
    before do
      add_option_author_resource
      visit '/admin/option_authors?q[name_cont]=Ja'
    end

    it 'counts the filtered records, not the whole table' do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 2 record(s).')
      expect(Author.count).to eq(3)
    end

    it 'counts the checked records only when a subset is checked' do
      find("#batch_action_item_#{Author.find_by(name: 'Jane').id}", visible: true).click
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 1 record(s).')
    end
  end

  # add_scoped_collection_records_count_action is called by every
  # scoped_collection_action, so the authors resource registers it four times.
  context 'registered by four scoped collection actions' do
    let(:resource) { ActiveAdmin.application.namespaces[:admin].resources['Author'] }

    before do
      add_author_resource
      visit '/admin/authors'
    end

    it 'leaves one batch action per declared action plus one count action' do
      expect(resource.scoped_collection_actions.keys).to match_array(
        [:scoped_collection_update, :scoped_collection_destroy,
         :scoped_collection_custom_visible, :scoped_collection_custom_hidden])
      expect(resource.batch_actions.map(&:sym)).to match_array(
        resource.scoped_collection_actions.keys + [:scoped_collection_records_count, :destroy])
    end

    it 'keeps the count action out of the batch actions dropdown' do
      expect(page).to have_css('.batch_actions_selector')
      offered = page.all('.batch_actions_selector a.batch_action', visible: :all)
                    .map { |link| link['data-action'] }
      expect(offered).to eq(['destroy'])
    end
  end

  # .except(:eager_load, :select, :order, :limit, :offset) in the count action.
  # Without it ActiveRecord counts through a subquery that keeps the limit and
  # answers 1 for a collection the action goes on to touch in full.
  context 'when the scope carries order and limit' do
    before do
      add_ordered_author_resource
      visit '/admin/ordered_authors'
    end

    it 'counts the unlimited total' do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 3 record(s).')
    end
  end
end
