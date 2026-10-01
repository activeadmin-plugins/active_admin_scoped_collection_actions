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

  # The action walks the relation with find_each, which honours limit and
  # offset, so the dialog has to answer with the same number. Measured on
  # ActiveRecord 8.0: find_each over a .limit(1) scope yields exactly one
  # record, so promising three would be promising records it never touches.
  context 'when the scope carries order and limit' do
    before do
      add_ordered_author_resource
      visit '/admin/ordered_authors'
    end

    it 'counts only what the limit lets the action reach' do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 1 record(s).')
    end
  end

  # A grouped relation answers .count with a Hash of per-group tallies, which
  # reaches the dialog as a JSON object and renders as [object Object].
  # Counting through a subquery collapses it to the number of rows the
  # relation yields, which is what find_each then walks.
  context 'when the scope is grouped' do
    before do
      # Two of the three authors share a birthday, so the grouped relation
      # yields two rows for three records -- and the count has to follow the
      # rows, because that is what find_each walks.
      Author.find_by(name: 'John').update!(birthday: '1980-01-01')
      Author.find_by(name: 'Jane').update!(birthday: '1980-01-01')
      Author.find_by(name: 'Jack').update!(birthday: '1990-02-02')
      add_grouped_author_resource
      visit '/admin/grouped_authors'
    end

    it 'counts the grouped rows as one number' do
      expect(Author.count).to eq(3)

      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      expect(page).to have_css('.dialog_records_summary',
                               text: 'You are going to delete 2 record(s).')
    end
  end
end
