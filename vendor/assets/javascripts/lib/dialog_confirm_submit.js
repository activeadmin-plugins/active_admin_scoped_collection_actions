// Second step of the fields dialog: instead of the fields it shows what is going to be
// changed and how many records are affected. "Back" returns to the filled form.
// form: dialog of ActiveAdmin.dialogMassFieldsUpdate
// options: {title: 'Are you sure?', summary: 'You are going to update {count} record(s) with:',
//           count: function returning jqXHR with {count: 100500}}
// changes: [{label: 'Name', value: 'test'}, ...]
ActiveAdmin.dialogConfirmSubmit = function(form, options, changes, callback){
  const widget = form.dialog('widget');
  const fieldsStep = { content: form.children(), title: form.dialog('option', 'title'), buttons: form.dialog('option', 'buttons') };

  const step = $('<div class="dialog_confirm_submit"></div>');
  const summary = options['summary'] ?
    ActiveAdmin.dialogRecordsSummary(options['summary'], options['count']).appendTo(step) : null;
  const list = $('<ul class="dialog_confirm_submit_changes"></ul>').appendTo(step);

  for (let change of Array.from(changes)) {
    $('<li></li>')
      .append($('<b></b>').text(change['label']))
      .append(document.createTextNode(`: ${change['value']}`))
      .appendTo(list);
  }

  fieldsStep.content.hide();
  step.appendTo(form);
  widget.addClass('active_admin_dialog_confirm_submit');

  form.dialog('option', {
    title: options['title'] || fieldsStep.title,
    buttons: {
      OK() {
        // amount of affected records is not known yet
        if (form.data('waiting')) { return; }

        return callback();
      },
      Back() {
        form.data('waiting', false);
        step.remove();
        fieldsStep.content.show();
        widget.removeClass('active_admin_dialog_confirm_submit');
        return form.dialog('option', { title: fieldsStep.title, buttons: fieldsStep.buttons });
      }
    }
  });

  if (summary) {
    ActiveAdmin.dialogSpinnerUntil(step.children(), summary.data('countRequest'));
    ActiveAdmin.dialogWaitFor(form, summary.data('countRequest'));
  }

  return form;
};
