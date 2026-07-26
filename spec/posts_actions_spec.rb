require 'spec_helper'

describe 'posts index', type: :feature, js: true do

  before do
    @john = Author.create!(name: 'John', last_name: 'Doe')
    @jane = Author.create!(name: 'Jane', last_name: 'Roe')

    Post.create!(title: 'John Post', body: '...', author: @john)
    Post.create!(title: 'Jane Post', body: '...', author: @jane)
  end

  before do
    add_post_resource
  end

  before do
    visit '/admin/posts'
  end

  context 'update posts body and author fields' do
    let(:new_body_text) { 'Text here...' }
    let(:new_author) { @jane }

    before do
      page.find('#collection_actions_sidebar_section button', text: 'Update').click
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('input#mass_update_dialog_body').click
        page.find('input[name="body"]').set(new_body_text)

        page.find('input#mass_update_dialog_author_id').click
        page.find('select[name="author_id"]').select(new_author.name)
        page.find('button', text: 'OK').click
      end
    end

    it 'asks for confirmation before submitting' do
      expect(page).to have_css('.active_admin_dialog_confirm_submit', text: 'Apply changes to all posts?')
      expect(Post.all.map(&:body).uniq).to_not match_array([new_body_text])
    end

    it 'shows amount of affected records and what is going to be changed' do
      page.within ('body>.active_admin_dialog_confirm_submit') do
        expect(page).to have_css('.dialog_records_summary',
                                 text: "You are going to update #{Post.count} record(s) with:")
        expect(page).to have_css('.dialog_confirm_submit_changes li', text: "Body: #{new_body_text}")
        expect(page).to have_css('.dialog_confirm_submit_changes li', text: "Author_id: #{new_author.name}")
      end
    end

    context 'when confirmed' do
      before do
        page.within ('body>.active_admin_dialog_confirm_submit') do
          page.find('button', text: 'OK').click
        end
      end

      it 'update successfully' do
        expect(page).to have_css('.flashes .flash.flash_notice')
        expect(Post.all.map(&:body).uniq).to match_array([new_body_text])
        expect(Post.all.map(&:author).uniq).to match_array([new_author])
      end
    end

    it 'replaces the fields with the summary instead of opening one more dialog' do
      expect(page).to have_css('body>.active_admin_dialog_mass_update_by_filter.active_admin_dialog_confirm_submit', count: 1)
      expect(page).to_not have_css('input[name="body"]', visible: true)
    end

    context 'when returned back' do
      before do
        page.within ('body>.active_admin_dialog_confirm_submit') do
          page.find('button', text: 'Back').click
        end
      end

      it 'keeps records untouched and shows filled form again' do
        expect(page).to_not have_css('.active_admin_dialog_confirm_submit')
        expect(page).to have_css('body>.active_admin_dialog_mass_update_by_filter')
        expect(page.find('input[name="body"]').value).to eq(new_body_text)
        expect(Post.all.map(&:body).uniq).to_not match_array([new_body_text])
      end
    end
  end

  context 'while amount of affected records is not known yet' do
    let(:new_body_text) { 'Text here...' }

    before do
      # count request never responds
      page.execute_script('ActiveAdmin.scopedCollectionRecordsCount = () => $.Deferred().promise()')
      page.find('#collection_actions_sidebar_section button', text: 'Update').click
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('input#mass_update_dialog_body').click
        page.find('input[name="body"]').set(new_body_text)
        page.find('button', text: 'OK').click
      end
    end

    it 'shows spinner instead of the summary and does not allow to confirm' do
      page.within ('body>.active_admin_dialog_confirm_submit') do
        expect(page).to have_css('.dialog_spinner')
        expect(page).to_not have_css('.dialog_records_summary')
        expect(page).to_not have_css('.dialog_confirm_submit_changes li')
        expect(page).to have_button('OK', disabled: true)
      end
      expect(page).to_not have_css('.flashes .flash.flash_notice')
      expect(Post.all.map(&:body).uniq).to_not match_array([new_body_text])
    end
  end

  context 'update only checked posts' do
    let(:new_body_text) { 'Text here...' }

    before do
      find("#batch_action_item_#{Post.first.id}", visible: true).click
      page.find('#collection_actions_sidebar_section button', text: 'Update').click
      page.within ('body>.active_admin_dialog_mass_update_by_filter') do
        page.find('input#mass_update_dialog_body').click
        page.find('input[name="body"]').set(new_body_text)
        page.find('button', text: 'OK').click
      end
    end

    it 'counts checked records only' do
      page.within ('body>.active_admin_dialog_confirm_submit') do
        expect(page).to have_css('.dialog_records_summary',
                                 text: 'You are going to update 1 record(s) with:')
      end
    end
  end

  context 'scoped collection action DELETE' do
    before do
      page.find('#collection_actions_sidebar_section button', text: 'Delete').click
    end

    context 'title' do
      it 'has predefined confirmation title' do
        expect(page).to have_css('.active_admin_dialog_mass_update_by_filter', text: 'Custom text for confirm delete all?')
      end
    end
  end

end
