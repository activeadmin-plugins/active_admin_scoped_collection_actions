#= require ./lib/aa_scoped_collection_actions_post_to_url
#= require ./lib/dialog_mass_fields_update

$(document).ready ->
  $('.show_form_mass_fields_update').click (e)->
    e.preventDefault()
    fields = JSON.parse( $(this).attr('data') )

    ActiveAdmin.dialog_mass_fields_update 'Mass records update by current filters', fields['inputs'],
      (inputs)=>
        url = window.location.pathname + '/batch_action' + window.location.search
        form_data = {
          changes: inputs,
          collection_selection: [],
          authenticity_token: $.parseJSON($(e.target).attr("data")).auth_token,
          batch_action: 'batch_update'
        }
        $('.paginated_collection').find('input.collection_selection:checked').each (i, el) ->
          form_data["collection_selection"].push($(el).val())

        aa_scoped_collection_actions_post_to_url(url, form_data)
