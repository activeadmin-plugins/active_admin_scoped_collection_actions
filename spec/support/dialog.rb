# Selectors for the action dialog, which is a jQuery UI dialog on ActiveAdmin 3
# and a Flowbite modal on ActiveAdmin 4.
module DialogHelpers
  def aa_v4?
    ActiveAdminScopedCollectionActions.aa_v4?
  end

  # The dialog, whichever step it shows.
  def dialog_css
    aa_v4? ? '[data-scoped-collection-action-modal]' : 'body>.active_admin_dialog_mass_update_by_filter'
  end

  # The dialog while it shows the second step of :confirm_submit.
  def confirm_step_css
    aa_v4? ? '[data-scoped-collection-action-modal][data-step="confirm"]' : 'body>.active_admin_dialog_mass_update_by_filter.active_admin_dialog_confirm_submit'
  end

  def flash_css(type)
    return ".flashes .flash.flash_#{type}" unless aa_v4?

    { notice: '.bg-green-50', error: '.bg-red-50' }.fetch(type)
  end

  def batch_actions_dropdown_css
    aa_v4? ? '.batch-actions-dropdown' : '.batch_actions_selector'
  end

  def batch_actions_dropdown_links
    css = aa_v4? ? '.batch-actions-dropdown-menu a[data-batch-action-item]' : '.batch_actions_selector a.batch_action'
    page.all(css, visible: :all)
  end

  # The count request never answers.
  def stall_records_count
    if aa_v4?
      page.execute_script(<<~JS)
        const fetchRecords = window.fetch
        window.fetch = (url, options) =>
          options.body.get('batch_action') === 'scoped_collection_records_count' ? new Promise(() => {}) : fetchRecords(url, options)
      JS
    else
      page.execute_script('ActiveAdmin.scopedCollectionRecordsCount = () => $.Deferred().promise()')
    end
  end

  # Picks today in the field of a 'datepicker' input.
  def pick_today(name)
    if aa_v4?
      page.find("#{dialog_css} input[name=\"#{name}\"]").set(Date.today)
    else
      page.within(dialog_css) { page.find("input[name=\"#{name}\"]").click }
      page.find('.ui-datepicker .ui-datepicker-days-cell-over.ui-datepicker-today', visible: true).click
    end
  end
end
