require 'spec_helper'

# :confirm_summary and :confirm_submit each accept true/false, a String or a
# Proc. Only one form of each is exercised elsewhere.
describe 'confirmation dialog options', type: :feature, js: true do

  before do
    Author.create!(name: 'John', last_name: 'Doe')
    Author.create!(name: 'Jane', last_name: 'Roe')
  end

  def button_data(title)
    JSON.parse(page.find('#collection_actions_sidebar_section button', text: title)['data'])
  end

  def fill_update_dialog(last_name)
    page.find('#collection_actions_sidebar_section button', text: 'Update').click
    page.within ('body>.active_admin_dialog_mass_update_by_filter') do
      page.find('input#mass_update_dialog_last_name').click
      page.find('input[name="last_name"]').set(last_name)
      page.find('button', text: 'OK').click
    end
  end

  describe ':confirm_summary' do

    context 'given a String' do
      before do
        add_option_author_resource(custom: {confirm_summary: 'Custom summary text.'})
        visit '/admin/option_authors'
      end

      it 'passes it through verbatim' do
        page.find('#collection_actions_sidebar_section button', text: 'Act').click
        expect(page).to have_css('.dialog_records_summary', text: 'Custom summary text.')
      end
    end

    context 'given a Proc' do
      before do
        add_option_author_resource(custom: {confirm_summary: -> { 'Summary from a proc.' }})
        visit '/admin/option_authors'
      end

      it 'calls it' do
        page.find('#collection_actions_sidebar_section button', text: 'Act').click
        expect(page).to have_css('.dialog_records_summary', text: 'Summary from a proc.')
      end
    end

    context 'given a Proc returning false' do
      before do
        add_option_author_resource(custom: {confirm_summary: -> { false }})
        visit '/admin/option_authors'
      end

      it 'leaves the data attribute out instead of emitting an empty one' do
        expect(button_data('Act')).to_not have_key('confirm_summary')
      end

      it 'shows the plain confirmation without a summary' do
        page.find('#collection_actions_sidebar_section button', text: 'Act').click
        expect(page).to have_css('.active_admin_dialog_mass_update_by_filter', text: 'Act on all?')
        # visible: :all - a configured summary is in the DOM from the start, it
        # is only hidden while the spinner waits for the count
        expect(page).to_not have_css('.dialog_records_summary', visible: :all)
      end
    end
  end

  describe ':confirm_submit' do

    context 'given true' do
      before do
        add_option_author_resource(update: {confirm_submit: true})
        visit '/admin/option_authors'
        fill_update_dialog('Smith')
      end

      it 'falls back to the confirm_action_message translation' do
        expect(page).to have_css('.active_admin_dialog_confirm_submit', text: 'Are you sure?')
        expect(page).to have_css('.dialog_records_summary',
                                 text: 'You are going to update 2 record(s) with:')
      end
    end

    context 'given a Proc returning false' do
      before do
        add_option_author_resource(update: {confirm_submit: -> { false }})
        visit '/admin/option_authors'
      end

      it 'leaves the data attributes out instead of emitting empty ones' do
        expect(button_data('Update')).to_not have_key('confirm_submit')
        expect(button_data('Update')).to_not have_key('confirm_submit_summary')
      end

      it 'submits without a second confirmation step' do
        # last_name is unique, so only one author is updated
        author = Author.first
        find("#batch_action_item_#{author.id}", visible: true).click
        fill_update_dialog('Smith')
        expect(page).to have_css('.flashes .flash.flash_notice')
        expect(author.reload.last_name).to eq('Smith')
      end
    end
  end
end
