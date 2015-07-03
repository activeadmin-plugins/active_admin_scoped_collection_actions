$(document).ready ->
  $('.show_form_mass_fields_update').click (e)->
    e.preventDefault()
    fields = JSON.parse( $(this).attr('data') )

    ActiveAdmin.dialog_mass_fields_update 'Mass records update by current filters', fields['inputs'],
      (inputs)=>
        url = window.location.pathname + '/batch_action' + window.location.search
        form_data = {
          changes: inputs,
          authenticity_token: $.parseJSON($(e.target).attr("data")).auth_token,
          batch_action: 'batch_update'
        }

        aa_scoped_collection_actions_post_to_url(url, form_data)
