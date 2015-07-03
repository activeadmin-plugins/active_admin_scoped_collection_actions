ActiveAdmin.dialog_mass_fields_update = (message, inputs, callback)->
  html = """<form id="dialog_confirm" title="#{message}"><div stype="padding-right:4px;padding-left:1px;margin-right:2px"><ul>"""
  for name, type of inputs
    if /^(datepicker|checkbox|text)$/.test type
      wrapper = 'input'
    else if type is 'textarea'
      wrapper = 'textarea'
    else if $.isArray type
      [wrapper, elem, opts, type] = ['select', 'option', type, '']
    else
      throw new Error "Unsupported input type: {#{name}: #{type}}"

    klass = if type is 'datepicker' then type else ''
    html += """<li>
      <input type='checkbox' class='mass_update_protect_fild_flag' value='Y' id="mass_update_dialog_#{name}" />
      <label for="mass_update_dialog_#{name}"> #{name.charAt(0).toUpperCase() + name.slice(1)}</label>
      <#{wrapper} name="#{name}" class="#{klass}" type="#{type}" disabled="disabled">""" +
        (if opts then (
          for v in opts
            $elem = $("<#{elem}/>")
            if $.isArray v
              $elem.text(v[0]).val(v[1])
            else
              $elem.text(v)
            $elem.wrap('<div>').parent().html()
        ).join '' else '')
    if wrapper == 'select'
      html += "</#{wrapper}>"
    html += "</li>"

    [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

  html += "</ul></div></form>"

  form = $(html).appendTo('body')

  $('body').trigger 'mass_update_modal_dialog:before_open', [form]

  form.dialog
    modal: true
    dialogClass: 'active_admin_dialog active_admin_dialog_mass_update_by_filter',
    maxHeight: window.innerHeight - window.innerHeight * 0.1,
    open: ->
      $('body').trigger 'mass_update_modal_dialog:after_open', [form]
      $('.mass_update_protect_fild_flag').on 'change', (e) ->
        if this.checked
          $(e.target).next().next().removeAttr('disabled').trigger("chosen:updated")
        else
          $(e.target).next().next().attr('disabled', 'disabled').trigger("chosen:updated")
    buttons:
      OK: (e)->
        $(e.target).closest('.ui-dialog-buttonset').html('<span>Processing. Please wait...</span>')
        callback $(@).serializeObject()
      Cancel: ->
        $('.mass_update_protect_fild_flag').off('change')
        $(@).dialog('close').remove()