require 'spec_helper'

describe 'authors index', type: :feature, js: true do

  before do
    Author.create!(name: 'John', last_name: 'Doe')
    Author.create!(name: 'Jane', last_name: 'Roe')
  end

  before do
    add_author_resource
  end

  before do
    visit '/admin/authors'
  end

  context 'show scoped collection action in sidebar' do

    it 'page has collection_actions_sidebar_section' do
      expect(page.find('#collection_actions_sidebar_section'))
          .to have_css('h3', text: 'Collection Actions')
      expect(page.find('#collection_actions_sidebar_section'))
          .to have_css('button', text: 'Update')
      expect(page.find('#collection_actions_sidebar_section'))
          .to have_css('button', text: 'Delete')
    end

  end


  context 'scoped collection action UPDATE' do
    before do
      @today = Date.today

      page.find('#collection_actions_sidebar_section button', text: 'Update').click
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('input#mass_update_dialog_birthday').click
        page.find('input[name="birthday"]').click
      end
      page.find('.ui-datepicker .ui-datepicker-days-cell-over.ui-datepicker-today', visible: true).click
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('button', text: 'OK').click
      end
    end

    it 'new birthday was set for all authors' do
      expect(page).to have_css('.flashes .flash.flash_notice')
      expect(Author.all.map(&:birthday).uniq.count).to eq(1)
      expect(Author.take.birthday).to eq(@today)
    end
  end


  context 'scoped collection action DELETE' do
    before do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
    end

    context 'title' do
      it 'has predefined confirmation title' do
        expect(page).to have_css('.active_admin_dialog_mass_update_by_filter', text: 'Delete all?')
      end
    end

    context 'action' do
      before do
        page.within ('body>.active_admin_dialog_mass_update_by_filter') do
          page.find('button', text: 'OK').click
        end
      end

      it 'delete all authors' do
        expect(page).to have_css('.flashes .flash.flash_notice')
        expect(Author.count).to eq(0)
      end
    end
  end


  context 'perform Delete-action when cheked only one item' do

    let(:delete_author) { Author.first }

    before do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
      page.find("#batch_action_item_#{delete_author.id}").trigger('click')
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('button', text: 'OK').click
      end
    end

    it 'delete only cheked author' do
      expect(page).to have_css('.flashes .flash.flash_notice')
      expect(Author.count).to eq(1)
      expect(Author.take.id).not_to eq(delete_author.id)
      expect(page).to have_css("#batch_action_item_#{Author.take.id}")
    end

  end

end
