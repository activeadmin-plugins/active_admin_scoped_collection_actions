#= require ./lib/aa_scoped_collection_actions_post_to_url
#= require ./lib/dialog_mass_fields_update

$(document).ready ->

  $('.aa_scoped_collection_destroy').click (e) ->
    if confirm('Are you shure?')
      $(e.target).attr('disabled', 'disabled').text('Processing...')
      url = window.location.pathname + '/batch_action' + window.location.search
      form_data = {
        collection_selection: [],
        authenticity_token: $.parseJSON($(e.target).attr("data")).auth_token,
        batch_action: 'batch_destroy'
      }
      $('.paginated_collection').find('input.collection_selection:checked').each (i, el) ->
        form_data["collection_selection"].push($(el).val())
      aa_scoped_collection_actions_post_to_url(url, form_data)


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
