//= require ./lib/dialog_mass_fields_update

$(document).ready(() =>

  $(document).on('click', '.scoped_collection_action_button', function(e) {
    e.preventDefault();
    const fields = JSON.parse( $(this).attr('data') );

    return ActiveAdmin.dialogMassFieldsUpdate(fields['confirm'], fields['inputs'],
      inputs=> {
        const url = window.location.pathname + '/batch_action' + window.location.search;
        const form_data = {
          changes: inputs,
          collection_selection: [],
          authenticity_token: fields['auth_token'],
          batch_action: fields['batch_action']
        };
        $('.paginated_collection').find('input.collection_selection:checked').each((i, el) => form_data["collection_selection"].push($(el).val()));

        return $.post(url, form_data).always(function(data, textStatus, jqXHR) {
          if (jqXHR.getResponseHeader('Location')) {
            return window.location.assign(jqXHR.getResponseHeader('Location'));
          } else {
            return window.location.reload();
          }
        });
    });
  })
);
