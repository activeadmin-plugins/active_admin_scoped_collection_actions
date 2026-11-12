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
