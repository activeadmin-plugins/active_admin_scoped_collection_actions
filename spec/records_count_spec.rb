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
