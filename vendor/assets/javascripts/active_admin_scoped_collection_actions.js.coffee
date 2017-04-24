#= require ./lib/dialog_mass_fields_update

$(document).ready ->

  $(document).on 'click', '.scoped_collection_action_button', (e) ->
    e.preventDefault()
    fields = JSON.parse( $(this).attr('data') )

    ActiveAdmin.dialogMassFieldsUpdate fields['confirm'], fields['inputs'],
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

        $.post(url, form_data).always (data, textStatus, jqXHR) ->
          if jqXHR.getResponseHeader('Location')
            window.location.assign jqXHR.getResponseHeader('Location')
          else
            window.location.reload()
