// Sentence about the records the action is going to be performed on,
// e.g. "You are going to delete 100500 record(s)."
// template: text where {count} is replaced with the amount
// countFn: function returning jqXHR with {count: 100500}
// @return [jQuery] paragraph, request promise is available as .data('countRequest')
ActiveAdmin.dialogRecordsSummary = function(template, countFn){
  const summary = $('<p class="dialog_records_summary"></p>');
  const showCount = count => summary.text(template.replace('{count}', count));

  if (!countFn) {
    showCount('');
    return summary.data('countRequest', $.Deferred().resolve().promise());
  }

  const request = countFn()
    .done(data => showCount(data['count']))
    .fail(() => showCount('?'));

  return summary.data('countRequest', request);
};

// Shows a spinner instead of the content until the promise is settled, so the user
// never sees a half of the message.
ActiveAdmin.dialogSpinnerUntil = function(content, promise){
  const spinner = $('<div class="dialog_spinner"></div>').insertBefore(content.first());

  content.hide();

  return promise.always(function(){
    spinner.remove();
    content.show();
  });
};

// Keeps OK of the dialog disabled while the promise is pending, so nothing can be
// confirmed before the user sees what they confirm.
ActiveAdmin.dialogWaitFor = function(dialog, promise){
  const button = dialog.dialog('widget').find('.ui-dialog-buttonset button').first();

  dialog.data('waiting', true);
  button.prop('disabled', true).addClass('ui-state-disabled');

  return promise.always(function(){
    dialog.data('waiting', false);
    button.prop('disabled', false).removeClass('ui-state-disabled');
  });
};
