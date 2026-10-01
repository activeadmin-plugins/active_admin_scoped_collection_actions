// Fields checked by the user with their values, as they are displayed in the dialog.
// @return [Array<Object>] [{label: 'Name', value: 'test'}, ...]
ActiveAdmin.dialogMassFieldsChanges = function(form){
  const changes = [];

  form.find('.mass_update_protect_fild_flag:checked').each(function() {
    const flag = $(this);
    const field = flag.nextAll('input, select, textarea').first();
    let value;

    if (field.is('select')) {
      value = field.find('option:selected').map((i, option) => $(option).text().trim()).get().join(', ');
    } else if (field.attr('type') === 'checkbox') {
      value = field.is(':checked');
    } else {
      value = field.val();
    }

    changes.push({ label: flag.next('label').text().trim(), value: value });
  });

  return changes;
};

// options: {summary: {text: 'You are going to delete {count} record(s).', count: countFn},
//           confirmSubmit: @see ActiveAdmin.dialogConfirmSubmit}
ActiveAdmin.dialogMassFieldsUpdate = function(message, inputs, callback, options){
  options = options || {};
  const confirmSubmit = options['confirmSubmit'];
  let html = `<form id="dialog_confirm" title="${message}"><div style="padding-right:4px;padding-left:1px;margin-right:2px"><ul>`;
  for (let name in inputs) {
    var elem, opts, wrapper;
    let type = inputs[name];
    let klass = '';
    if ($.isPlainObject(type)) {
      // {type: 'text', class: 'my-widget'} - input rendered with your own class,
      // so it can be turned into any widget by your own JS
      [wrapper, klass, type] = Array.from(['input', type['class'] || '', type['type'] || 'text']);
    } else if (/^(datepicker|checkbox|text)$/.test(type)) {
      wrapper = 'input';
      klass = type === 'datepicker' ? type : '';
    } else if ($.isArray(type)) {
      [wrapper, elem, opts, type] = Array.from(['select', 'option', type, '']);
    } else {
      throw new Error(`Unsupported input type: {${name}: ${type}}`);
    }

    html += `<li>
<input type='checkbox' class='mass_update_protect_fild_flag' value='Y' id="mass_update_dialog_${name}" />
<label for="mass_update_dialog_${name}"> ${name.charAt(0).toUpperCase() + name.slice(1)}</label>
<${wrapper} name="${name}" class="${klass}" type="${type}" disabled="disabled">` +
        (opts ? ((() => {
          const result = [];

          for (let v of Array.from(opts)) {
            const $elem = $(`<${elem}/>`);
            if ($.isArray(v)) {
              $elem.text(v[0]).val(v[1]);
            } else {
              $elem.text(v);
            }
            result.push($elem.wrap('<div>').parent().html());
          }

          return result;
        })()).join('') : '');
    if (wrapper === 'select') {
      html += `</${wrapper}>`;
    }
    html += "</li>";

    [wrapper, elem, opts, type, klass] = Array.from([]);
  } // unset any temporary variables

  html += "</ul></div></form>";

  const form = $(html).appendTo('body');

  const summary = options['summary'] ?
    ActiveAdmin.dialogRecordsSummary(options['summary']['text'], options['summary']['count']).prependTo(form) : null;

  $('body').trigger('mass_update_modal_dialog:before_open', [form]);

  const dialog = form.dialog({
    modal: true,
    classes: { 'ui-dialog': 'ui-corner-all active_admin_dialog active_admin_dialog_mass_update_by_filter' },
    dialogClass: 'active_admin_dialog active_admin_dialog_mass_update_by_filter',
    maxHeight: window.innerHeight - (window.innerHeight * 0.1),
    open() {
      $('body').trigger('mass_update_modal_dialog:after_open', [form]);
      return $('.mass_update_protect_fild_flag').on('change', function(e) {
        if (this.checked) {
          return $(e.target).next().next().removeAttr('disabled').trigger("chosen:updated");
        } else {
          return $(e.target).next().next().attr('disabled', 'disabled').trigger("chosen:updated");
        }
      });
    },
    buttons: {
      OK(){
        // amount of affected records is not known yet
        if (form.data('waiting')) { return; }

        const submit = () => {
          form.dialog('widget').find('.ui-dialog-buttonset').html('<span>Processing. Please wait...</span>');
          return callback(form.serializeObject());
        };
        const changes = ActiveAdmin.dialogMassFieldsChanges(form);
        // nothing is checked - there is nothing to confirm
        if (!confirmSubmit || !changes.length) { return submit(); }
        return ActiveAdmin.dialogConfirmSubmit(form, confirmSubmit, changes, submit);
      },
      Cancel() {
        $('.mass_update_protect_fild_flag').off('change');
        return $(this).dialog('close').remove();
      }
    }
  });

  if (summary) {
    ActiveAdmin.dialogSpinnerUntil(summary, summary.data('countRequest'));
    ActiveAdmin.dialogWaitFor(form, summary.data('countRequest'));
  }

  return dialog;
};
