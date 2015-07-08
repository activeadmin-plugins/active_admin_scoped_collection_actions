#= require ./lib/dialog_mass_fields_update

$(document).ready ->

  $('.scoped_collection_action_button').click (e) ->
    e.preventDefault()
    fields = JSON.parse( $(this).attr('data') )

    ActiveAdmin.dialog_mass_fields_update fields['confirm'], fields['inputs'],
      (inputs)=>
        url = window.location.pathname + '/batch_action' + window.location.search
        form_data = {
          changes: inputs,
          collection_selection: [],
          authenticity_token: fields['auth_token'],
          batch_action: fields['batch_action']
        }
        $('.paginated_collection').find('input.collection_selection:checked').each (i, el) ->
          form_data["collection_selection"].push($(el).val())

        $.post(url, form_data).always () ->
          window.location.reload()
