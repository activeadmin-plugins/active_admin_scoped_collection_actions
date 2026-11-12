// ActiveAdmin 4 dialog; ActiveAdmin 3 keeps the jQuery UI one in vendor/assets.
// Posts the same params as that one: changes[name], collection_selection[],
// authenticity_token and batch_action.
import "flowbite"

const BUTTON = ".scoped_collection_action_button"
const COUNT_ACTION = "scoped_collection_records_count"

const PRIMARY_BUTTON = "text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-hidden focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 cursor-pointer disabled:opacity-50 disabled:cursor-default dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
const SECONDARY_BUTTON = "action-item-button cursor-pointer"
const INPUT = "block w-full mt-1 rounded-md border border-gray-300 bg-white text-sm text-gray-900 disabled:opacity-50 dark:border-gray-600 dark:bg-gray-700 dark:text-white"
const CHECKBOX = "rounded-sm border-gray-300 dark:border-gray-600 dark:bg-gray-700"

const element = (tag, attributes = {}, text = null) => {
  const el = document.createElement(tag)
  for (const [name, value] of Object.entries(attributes)) {
    if (value !== null && value !== undefined) el.setAttribute(name, value)
  }
  if (text !== null) el.textContent = text
  return el
}

const batchActionUrl = () => window.location.pathname + "/batch_action" + window.location.search

const selection = () =>
  Array.from(document.querySelectorAll('input[name="collection_selection[]"]:checked'), (input) => input.value)

const post = (token, batchAction, changes = {}) => {
  const body = new URLSearchParams()
  for (const [name, value] of Object.entries(changes)) body.append(`changes[${name}]`, value)
  for (const id of selection()) body.append("collection_selection[]", id)
  body.append("authenticity_token", token)
  body.append("batch_action", batchAction)

  return fetch(batchActionUrl(), {
    method: "POST",
    body,
    credentials: "same-origin",
    headers: { "X-Requested-With": "XMLHttpRequest" }
  })
}

const recordsCount = (token) =>
  post(token, COUNT_ACTION).then((response) => (response.ok ? response.json() : Promise.reject(response)))

// "You are going to delete {count} record(s).", hidden behind a spinner until
// the count is known, so nobody reads half a message.
const recordsSummary = (template, token) => {
  const summary = element("p", { class: "dialog_records_summary mb-2 text-gray-900 dark:text-gray-100", "data-scoped-collection-action-summary": "" })
  const spinner = element("div", { class: "dialog_spinner mx-auto my-4 size-6 animate-spin rounded-full border-3 border-current border-r-transparent text-gray-500 dark:text-gray-400", "data-scoped-collection-action-spinner": "" })
  const show = (count) => { summary.textContent = template.replace("{count}", count) }

  summary.hidden = true
  const request = recordsCount(token)
    .then((data) => show(data.count))
    .catch(() => show("?"))
    .finally(() => {
      spinner.remove()
      summary.hidden = false
    })

  return { summary, spinner, request }
}

// One field of the `form:` option: a checkbox that enables it, a label and
// the input. Unchecked fields stay disabled and are not submitted.
const field = (name, type) => {
  const id = `mass_update_dialog_${name}`
  const item = element("li", { class: "mt-3", "data-scoped-collection-action-field": name })
  const toggle = element("input", { type: "checkbox", class: `mass_update_protect_fild_flag ${CHECKBOX}`, value: "Y", id })
  const label = element("label", { for: id, class: "ms-2 text-sm font-medium text-gray-900 dark:text-white" }, name.charAt(0).toUpperCase() + name.slice(1))
  let input

  if (Array.isArray(type)) {
    input = element("select", { name, class: INPUT })
    for (const option of type) {
      const [text, value] = Array.isArray(option) ? option : [option, option]
      input.append(element("option", { value }, text))
    }
  } else if (type !== null && typeof type === "object") {
    // {type: 'text', class: 'my-widget'}: a plain input carrying the host's
    // class, so its own JavaScript can turn it into any widget.
    input = element("input", { name, type: type.type || "text", class: `${type.class || ""} ${INPUT}` })
  } else if (type === "text") {
    input = element("input", { name, type: "text", class: INPUT })
  } else if (type === "checkbox") {
    input = element("input", { name, type: "checkbox", class: `ms-2 ${CHECKBOX}` })
  } else if (type === "datepicker") {
    // ActiveAdmin 4 uses the native date input instead of a datepicker widget.
    input = element("input", { name, type: "date", class: `datepicker ${INPUT}` })
  } else {
    throw new Error(`Unsupported input type: {${name}: ${type}}`)
  }

  input.disabled = true
  toggle.addEventListener("change", () => { input.disabled = !toggle.checked })
  item.append(toggle, label, input)
  return item
}

// The checked fields as the dialog shows them: [{label: 'Name', value: 'test'}]
const checkedChanges = (form) =>
  Array.from(form.querySelectorAll(".mass_update_protect_fild_flag:checked"), (toggle) => {
    const item = toggle.closest("[data-scoped-collection-action-field]")
    const input = item.querySelector("[name]")
    let value
    if (input.tagName === "SELECT") {
      value = Array.from(input.selectedOptions, (option) => option.text.trim()).join(", ")
    } else if (input.type === "checkbox") {
      value = input.checked
    } else {
      value = input.value
    }
    return { label: item.querySelector("label").textContent.trim(), value }
  })

const formChanges = (form) => {
  const changes = {}
  for (const [name, value] of new FormData(form)) changes[name] = value
  return changes
}

const openDialog = (button) => {
  const data = JSON.parse(button.getAttribute("data"))
  const token = data.auth_token
  const batchAction = data.batch_action
  // confirm_submit adds a second step, and confirm_summary then only words it
  const confirmSubmit = data.confirm_submit
    ? { title: data.confirm_submit, summary: data.confirm_summary || data.confirm_submit_summary }
    : null
  const summaryText = confirmSubmit ? null : data.confirm_summary

  const modalEl = element("div", {
    id: "scoped-collection-action-modal",
    tabindex: "-1",
    "aria-hidden": "true",
    class: "fixed inset-0 z-50 hidden w-full p-4 overflow-x-hidden overflow-y-auto h-full max-h-full",
    "data-scoped-collection-action-modal": batchAction,
    "data-step": "fields"
  })
  const dialog = element("div", { class: "relative w-full max-w-md max-h-full" })
  const content = element("div", { class: "relative bg-white rounded-lg shadow dark:bg-gray-800 dark:border dark:border-white/10 px-6 py-6 lg:px-8" })
  const title = element("h3", { class: "mb-4 text-xl font-medium text-gray-900 dark:text-white", "data-scoped-collection-action-title": "" }, data.confirm)
  const form = element("form", { "data-scoped-collection-action-form": batchAction })
  const fields = element("ul", { "data-scoped-collection-action-fields": "" })
  const footer = element("div", { class: "mt-6 flex justify-end gap-2" })
  const ok = element("button", { type: "submit", class: PRIMARY_BUTTON, "data-scoped-collection-action-ok": "" }, "OK")
  const cancel = element("button", { type: "button", class: SECONDARY_BUTTON, "data-scoped-collection-action-cancel": "" }, "Cancel")

  for (const [name, type] of Object.entries(data.inputs || {})) fields.append(field(name, type))
  footer.append(ok, cancel)
  form.append(fields, footer)
  content.append(title, form)
  dialog.append(content)
  modalEl.append(dialog)
  document.body.append(modalEl)

  // OK stays disabled while the count is pending, so nothing is confirmed
  // before the user sees what they confirm.
  let waiting = null
  const waitFor = (request) => {
    waiting = request
    ok.disabled = true
    request.finally(() => {
      if (waiting !== request) return
      waiting = null
      ok.disabled = false
    })
  }

  if (summaryText) {
    const { summary, spinner, request } = recordsSummary(summaryText, token)
    form.prepend(spinner, summary)
    waitFor(request)
  }

  const modal = new window.Modal(modalEl, {
    backdrop: "dynamic",
    closable: true,
    onHide: () => {
      setTimeout(() => {
        modal.destroyAndRemoveInstance()
        modalEl.remove()
      })
    }
  }, { id: modalEl.id, override: true })

  cancel.addEventListener("click", () => modal.hide())

  const submit = () => {
    const changes = formChanges(form)
    footer.replaceChildren(element("span", { class: "text-sm text-gray-700 dark:text-gray-300" }, "Processing. Please wait..."))
    post(token, batchAction, changes)
      .then((response) => {
        const location = response.headers.get("Location")
        if (location) window.location.assign(location)
        else window.location.reload()
      })
      .catch(() => window.location.reload())
  }

  // Second step: the fields give way to what is going to change and on how
  // many records. Back returns to the filled-in fields.
  const showConfirmStep = (changes) => {
    const step = element("div", { class: "dialog_confirm_submit", "data-scoped-collection-action-confirm": "" })
    const list = element("ul", { class: "dialog_confirm_submit_changes mt-1 text-sm text-gray-900 dark:text-gray-100" })
    for (const change of changes) {
      const item = element("li", { class: "mt-1" })
      item.append(element("b", {}, change.label), document.createTextNode(`: ${change.value}`))
      list.append(item)
    }
    const { summary, spinner, request } = recordsSummary(confirmSubmit.summary, token)
    list.hidden = true
    request.finally(() => { list.hidden = false })
    step.append(spinner, summary, list)

    const back = element("button", { type: "button", class: SECONDARY_BUTTON, "data-scoped-collection-action-back": "" }, "Back")
    const fieldsTitle = title.textContent
    back.addEventListener("click", () => {
      waiting = null
      ok.disabled = false
      step.remove()
      back.replaceWith(cancel)
      fields.hidden = false
      title.textContent = fieldsTitle
      modalEl.dataset.step = "fields"
    })

    fields.hidden = true
    fields.after(step)
    cancel.replaceWith(back)
    title.textContent = confirmSubmit.title || fieldsTitle
    modalEl.dataset.step = "confirm"
    waitFor(request)
  }

  form.addEventListener("submit", (event) => {
    event.preventDefault()
    if (waiting) return

    if (modalEl.dataset.step === "confirm") return submit()

    const changes = checkedChanges(form)
    // nothing is checked, so there is nothing to confirm
    if (!confirmSubmit || !changes.length) return submit()
    showConfirmStep(changes)
  })

  document.body.dispatchEvent(new CustomEvent("mass_update_modal_dialog:before_open", { bubbles: true, detail: { form } }))
  modal.show()
  document.body.dispatchEvent(new CustomEvent("mass_update_modal_dialog:after_open", { bubbles: true, detail: { form } }))
}

document.addEventListener("click", (event) => {
  const button = event.target.closest(BUTTON)
  if (!button) return

  event.preventDefault()
  openDialog(button)
})
