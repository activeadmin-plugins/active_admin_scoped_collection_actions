//= require ./lib/dialog_records_summary
//= require ./lib/dialog_mass_fields_update
//= require ./lib/dialog_confirm_submit

ActiveAdmin.scopedCollectionBatchActionUrl = function(){
  return window.location.pathname + '/batch_action' + window.location.search;
};

ActiveAdmin.scopedCollectionSelection = function(){
  const selection = [];
  $('.paginated_collection').find('input.collection_selection:checked').each((i, el) => selection.push($(el).val()));
  return selection;
};

// Amount of records the action is going to be performed on. Same scope(filters,
// current scope and checked records) as the action itself uses.
ActiveAdmin.scopedCollectionRecordsCount = function(authToken){
  return $.post(ActiveAdmin.scopedCollectionBatchActionUrl(), {
    batch_action: 'scoped_collection_records_count',
    authenticity_token: authToken,
    collection_selection: ActiveAdmin.scopedCollectionSelection()
  });
};

$(document).ready(() =>

  $(document).on('click', '.scoped_collection_action_button', function(e) {
    e.preventDefault();
    const fields = JSON.parse( $(this).attr('data') );

    const count = () => ActiveAdmin.scopedCollectionRecordsCount(fields['auth_token']);
    const options = {};

    if (fields['confirm_submit']) {
      // fields dialog gets a second step with the summary of what is going to be done
      options['confirmSubmit'] = {
        title: fields['confirm_submit'],
        summary: fields['confirm_summary'] || fields['confirm_submit_summary'],
        count: count
      };
    } else if (fields['confirm_summary']) {
      // dialog itself tells what is going to be done
      options['summary'] = { text: fields['confirm_summary'], count: count };
    }

    return ActiveAdmin.dialogMassFieldsUpdate(fields['confirm'], fields['inputs'],
      inputs=> {
        const url = ActiveAdmin.scopedCollectionBatchActionUrl();
        const form_data = {
          changes: inputs,
          collection_selection: ActiveAdmin.scopedCollectionSelection(),
          authenticity_token: fields['auth_token'],
          batch_action: fields['batch_action']
        };

        return $.post(url, form_data).always(function(data, textStatus, jqXHR) {
          if (jqXHR.getResponseHeader('Location')) {
            return window.location.assign(jqXHR.getResponseHeader('Location'));
          } else {
            return window.location.reload();
          }
        });
    }, options);
  })
);
