require 'spec_helper'

# The ActiveAdmin 4 modal; the shared specs cover what it does with the records.
describe 'ActiveAdmin 4 dialog', type: :feature, js: true do
  before do
    skip 'ActiveAdmin 4 only' unless ActiveAdminScopedCollectionActions.aa_v4?

    Author.create!(name: 'John', last_name: 'Doe')
    add_author_resource
    visit '/admin/authors'
  end

  it 'marks the button, the modal and its form with data attributes' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click

    expect(page).to have_css('[data-scoped-collection-action-modal="scoped_collection_update"]' \
      ' form[data-scoped-collection-action-form="scoped_collection_update"]' \
      ' [data-scoped-collection-action-field="last_name"]')
  end

  it 'names the modal after its heading' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click

    expect(page).to have_css('[data-scoped-collection-action-modal][aria-labelledby="scoped-collection-action-modal-title"]' \
      ' h3#scoped-collection-action-modal-title')
  end

  it 'tells host scripts the dialog opened, with the form in the event detail' do
    page.execute_script(<<~JS)
      document.addEventListener('mass_update_modal_dialog:after_open', (event) => {
        window.openedForm = event.detail.form.dataset.scopedCollectionActionForm
      })
    JS
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click

    expect(page).to have_css(dialog_css)
    expect(page.evaluate_script('window.openedForm')).to eq('scoped_collection_update')
  end

  it 'removes the modal on Cancel' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click
    page.within(dialog_css) { page.find('button', text: 'Cancel').click }

    expect(page).to_not have_css(dialog_css, visible: :all)
    expect(Author.count).to eq(1)
  end

  it 'moves focus into the modal' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click

    expect(page).to have_css("#{dialog_css} input:focus")
  end

  it 'names each value control after its field label' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click
    expect(page).to have_css(dialog_css)

    names = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('[data-scoped-collection-action-modal] [name]'), (input) =>
        (input.getAttribute('aria-labelledby') || '').split(' ').map((id) => document.getElementById(id)?.textContent).join(' '))
    JS
    expect(names).to eq(%w[Birthday Last_name])
  end

  it 'returns focus to the opening button on Cancel' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click
    page.within(dialog_css) { page.find('button', text: 'Cancel').click }

    expect(page).to_not have_css(dialog_css, visible: :all)
    expect(page.evaluate_script('document.activeElement.dataset.scopedCollectionAction')).to eq('scoped_collection_update')
  end

  it 'returns focus to the opening button on Escape' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click
    expect(page).to have_css("#{dialog_css} input:focus")
    page.find("#{dialog_css} input:focus").send_keys(:escape)

    expect(page).to_not have_css(dialog_css, visible: :all)
    expect(page.evaluate_script('document.activeElement.dataset.scopedCollectionAction')).to eq('scoped_collection_update')
  end

  it 'keeps the modal open on Escape once the action is sent' do
    page.find('[data-scoped-collection-action="scoped_collection_update"]').click
    expect(page).to have_css(dialog_css)
    page.execute_script('window.fetch = () => new Promise(() => {})')
    page.within(dialog_css) { page.find('button', text: 'OK').click }
    expect(page).to have_css(dialog_css, text: 'Processing')
    page.find('body').send_keys(:escape)

    expect(page).to have_css(dialog_css, text: 'Processing')
  end
end

describe 'ActiveAdmin 4 dialog with confirm_submit', type: :feature, js: true do
  before do
    skip 'ActiveAdmin 4 only' unless ActiveAdminScopedCollectionActions.aa_v4?

    add_post_resource
    visit '/admin/posts'
  end

  it 'moves focus back into the fields when Back is pressed with the keyboard' do
    page.find('#collection_actions_sidebar_section button', text: 'Update').click
    page.within(dialog_css) do
      page.find('input#mass_update_dialog_body').click
      page.find('input[name="body"]').set('Text')
      page.find('button', text: 'OK').click
    end
    expect(page).to have_css(confirm_step_css)
    # Cuprite's send_keys does not focus a button, so focus it and press Enter
    page.execute_script("document.querySelector('[data-scoped-collection-action-back]').focus()")
    page.driver.browser.keyboard.type(:enter)

    expect(page).to have_css('[data-scoped-collection-action-modal][data-step="fields"]')
    expect(page.evaluate_script(
      "document.querySelector('[data-scoped-collection-action-modal]').contains(document.activeElement)"
    )).to be(true)
  end
end
