[![Build Status](https://github.com/activeadmin-plugins/active_admin_scoped_collection_actions/actions/workflows/ci.yml/badge.svg)](https://github.com/activeadmin-plugins/active_admin_scoped_collection_actions/actions/workflows/ci.yml)
![Coverage](https://img.shields.io/endpoint?url=https://activeadmin-plugins.github.io/active_admin_scoped_collection_actions/badge.json)

# ActiveAdmin Scoped Collection Actions

Plugin for ActiveAdmin. Provides batch Update and Delete for scoped_collection (Filters + Scope) across all pages.

![Collection actions in the ActiveAdmin sidebar](/screenshots/sidebar.png)

![The confirmation dialog with the update form](/screenshots/pupup.png)

## Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
  - [Update action](#update-action)
- [Custom actions](#custom-actions)
- [Details and settings](#details-and-settings)
  - [Why don't I see the sidebar with collection actions?](#why-dont-i-see-the-sidebar-with-collection-actions)
  - [Can I use my own handler for the update and delete actions?](#can-i-use-my-own-handler-for-the-update-and-delete-actions)
  - [How can I rename a button?](#how-can-i-rename-a-button)
  - [How can I change the modal dialog title?](#how-can-i-change-the-modal-dialog-title)
  - [How can I tell the user how many records are affected?](#how-can-i-tell-the-user-how-many-records-are-affected)
  - [How can I ask for an extra confirmation before the form is submitted?](#how-can-i-ask-for-an-extra-confirmation-before-the-form-is-submitted)
  - [Can I replace the pop-up form with my own?](#can-i-replace-the-pop-up-form-with-my-own)
  - [How do I notify the user about success and errors?](#how-do-i-notify-the-user-about-success-and-errors)
  - [Can I perform an action only on selected items?](#can-i-perform-an-action-only-on-selected-items)
- [License](#license)

## Description

This gem gives you the ability to perform various batch actions on any filtered (or scoped) resource. An action
applies to all records across all pages. It is similar to an ActiveAdmin batch action, but affects all filtered
records. This is useful when you want to delete or update a lot of records in one click.

## Installation

Add this line to your application's Gemfile:

```ruby
# last version
gem 'active_admin_scoped_collection_actions'
# master branch
gem 'active_admin_scoped_collection_actions', github: 'activeadmin-plugins/active_admin_scoped_collection_actions'
```

And then execute:

```sh
bundle
```

Add the following line at the end of `app/assets/javascript/active_admin.js`:

```javascript
//= require active_admin_scoped_collection_actions
```

Also include the CSS in `app/assets/stylesheets/active_admin.css.scss`:

```scss
@import "active_admin_scoped_collection_actions";
```

## Usage

Usually you need two standard actions: Delete and Update.

For example, if you have resource Posts and you want to have a delete action, add:

```ruby
scoped_collection_action :scoped_collection_destroy
```

Example:

```ruby
ActiveAdmin.register Post do
  config.batch_actions = true

  scoped_collection_action :scoped_collection_destroy

  index do
    # ...
  end
end
```

> **Important**
> Visit the Posts page with your browser and you will see no changes. Now, perform any filter with the Filters
> sidebar. Only after you filter will you see a delete button. It will be in the sidebar under Filters.

### Update action

Update is the second standard action and is more complex. It has a `form` hash wrapped in a Proc:

```ruby
scoped_collection_action :scoped_collection_update, form: -> do
  { name: 'text',
    diagonal: 'text',
    manufactured_at: 'datepicker',
    vendor_id: Vendor.all.map { |region| [region.name, region.id] },
    has_3g: [['Yes', 't'], ['No', 'f']] }
end
```

In this example the Phone model has fields:

- `name` — varchar string
- `diagonal` — integer (or float)
- `manufactured_at` — datetime
- `vendor_id` — association `belongs_to :vendor, class_name: 'Vendor', foreign_key: :vendor_id`
- `has_3g` — boolean

The `form` parameter is a Proc which returns a Hash. It defines which fields you want to be able to update. Hash
keys are column names in the database, hash values are types of HTML inputs. Supported values are `text`,
`checkbox`, `datepicker`, and an Array of options for a selectbox. If you want something more complex, you can
build your own forms.

A field value can also be a Hash, `{type: 'text', class: 'my-widget'}`. Such a field is rendered as a plain input
with your own class on it, so you can turn it into any widget (datetime picker, autocomplete, etc.) with your own
JavaScript. The dialog triggers the `mass_update_modal_dialog:after_open` event on `body` with the form as an
argument — this is the place to initialize your widgets:

```javascript
$(document).on('mass_update_modal_dialog:after_open', function (event, form) {
  $(form).find('input.my-widget').myWidget();
});
```

## Custom actions

Example: we have a Phone resource with a `manufactured_at` column. We need an action which will erase this date.

In the ActiveAdmin resource:

```ruby
ActiveAdmin.register Phone do
  config.batch_actions = true

  scoped_collection_action :erase_date do
    scoped_collection_records.update_all(manufactured_at: nil)
  end

  index do
    # ...
  end
end
```

This simple code will create a new "Erase date" button in the sidebar. After clicking it, the user will see the
confirmation message "Are you sure?". After confirming, all filtered records will be updated.

## Details and settings

### Why don't I see the sidebar with collection actions?

Sidebar visibility by default depends on several things.

First you must set:

```ruby
config.batch_actions = true
```

Internally this gem uses `batch_actions`, so without them collection actions will not work.

```ruby
scoped_collection_action :something_here
```

Your resource should have some collection actions. If it does not have any, the sidebar will not appear.

By default we do not allow performing actions on **all** the records — this protects you from accidental
deletion. The sidebar with buttons appears only after you filter or scope the resource records.

And lastly, you can manage sidebar visibility through the resource config:

```ruby
# Always
config.scoped_collection_actions_if = -> { true }
# Only for scopes
config.scoped_collection_actions_if = -> { params[:scope] }
# etc.
```

You can also manage the visibility of each action individually:

```ruby
scoped_collection_action :scoped_collection_destroy, if: proc { can? :destroy, Blog }
```

### Can I use my own handler for the update and delete actions?

You can pass a block to the default update and delete actions, and do a custom redirect after it. Use `head`
with a `location:` instead of `redirect_to`.

This example renders a form which allows changing the `name` field, and after that redirects to the dashboard
page:

```ruby
scoped_collection_action :scoped_collection_update,
                         form: -> {
                           { name: 'text' }
                         } do
  scoped_collection_records.update_all(name: params[:changes][:name])
  flash[:notice] = 'Name successfully changed.'
  head :no_content, location: admin_dashboard_path
end
```

### How can I rename a button?

Every `scoped_collection_action` has the `:title` option.

Example:

```ruby
scoped_collection_action :erase_date, title: 'Nullify' do
  scoped_collection_records.update_all(manufactured_at: nil)
end
```

### How can I change the modal dialog title?

Similar to the button title — use the `:confirm` option:

```ruby
scoped_collection_action :scoped_collection_destroy, confirm: 'Delete all phones?'
```

### How can I tell the user how many records are affected?

The `:confirm_summary` option adds a sentence with the number of affected records to the dialog:

```ruby
scoped_collection_action :scoped_collection_destroy, confirm_summary: true
```

```text
Delete all?

You are going to delete 100500 record(s).

                                   [ OK ] [ Cancel ]
```

`true` uses the default text — the `confirm_destroy_summary` locale key for `:scoped_collection_destroy` and
`confirm_action_summary` for any other action. Pass a String or a Proc to use your own text. `{count}` in the
text is replaced with the number.

The amount is requested when the dialog is opened, with the same filters, scope and checked records the action
itself will use, so it costs one extra COUNT query per opened dialog. Until it arrives the message is not
displayed at all — there is a spinner in its place and OK is disabled, so nothing can be confirmed before the
user sees what they confirm. An action that sets neither `:confirm_summary` nor `:confirm_submit` counts nothing
and requests nothing — `:confirm_submit` shows the same sentence on its second step, so it counts too.

Both options in one flow — an update action with `confirm_submit:` and the summary it shows, from the sidebar
button to the result:

![confirm_summary and confirm_submit](/screenshots/example_confirm_summary.png)

### How can I ask for an extra confirmation before the form is submitted?

An action without a form is confirmed by the modal dialog itself — it has no fields and the user just presses OK.
An action with a form applies changes immediately after OK is pressed. Use the `:confirm_submit` option to turn
such an action into two steps, where the second one replaces the fields with a summary of what is going to
happen:

```ruby
scoped_collection_action :scoped_collection_update,
                         confirm_submit: true,
                         form: -> { { body: 'text' } }
```

```text
Are you sure?

You are going to update 100500 record(s) with:
  Body: Text here...
  Author_id: Jane

                                     [ OK ] [ Back ]
```

"Back" returns to the form with everything the user filled in still there. Only the fields the user checked are
listed, and when nothing is checked there is nothing to confirm — the action is performed right away. The text of
the sentence is the `confirm_submit_summary` locale key, or the `:confirm_summary` option when you set it.

`true` shows the default message ("Are you sure?"). Pass a String or a Proc to use your own:

```ruby
scoped_collection_action :scoped_collection_update,
                         confirm_submit: 'Update all filtered phones?',
                         form: -> { { name: 'text' } }
```

### Can I replace the pop-up form with my own?

Yes, but you must also take care of the mandatory parameters passed to the server.

```ruby
scoped_collection_action :my_pop_action, class: 'my_popup'
```

Now in the HTML page you have a button:

```html
<button class="my_popup" data="{&quot;auth_token&quot;:&quot;2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0=&quot;,&quot;batch_action&quot;:&quot;my_pop_action&quot;,&quot;confirm&quot;:&quot;Are you sure?&quot;}">My pop action</button>
```

Without a handler, clicking the button does nothing.

You can render the form in any way you want:

- it can be a popup (Fancybox, Simplemodal, etc.), or an inline collapsible form;
- it can even be a separate full page.

One thing is important — how you send the data to the server. It should be:

| | |
| --- | --- |
| Method | `POST` |
| URL | `/admin/collection_path/batch_action` |
| Query string | identical to the current page |

The easiest way to build it is:

```javascript
url = window.location.pathname + '/batch_action' + window.location.search
```

And the request body params should look like:

```text
changes[manufactured_at] = "2015-07-21 18:11"
changes[diagonal] = "7"
changes[some_filed_name]='new value'
authenticity_token = "2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0="
batch_action = "my_pop_action"
```

`authenticity_token` and `batch_action` can be taken from the data attribute of the button.

Example in JavaScript:

```javascript
url = window.location.pathname + '/batch_action' + window.location.search
form_data = {
  changes: { "manufactured_at": "2015-07-21 18:11", "diagonal": "7" },
  collection_selection: [],
  authenticity_token: "2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0=",
  batch_action: "my_pop_action"
}
$.post(url, form_data).always(function () {
  window.location.reload();
});
```

### How do I notify the user about success and errors?

We recommend using Rails flash messages.

Example with updating the phone diagonal attribute. In this case the Phone model has a validation:

```ruby
class Phone < ActiveRecord::Base
  validates :diagonal, numericality: { only_integer: true }
end
```

```ruby
scoped_collection_action :change_diagonal, form: { diagonal: 'text' } do
  errors = []
  scoped_collection_records.find_each do |record|
    errors << record.errors.full_messages.join('. ') unless record.update(diagonal: params[:changes][:diagonal])
  end
  if errors.empty?
    flash[:notice] = 'Diagonal changed successfully'
  else
    flash[:error] = errors.join('. ')
  end
  head :no_content
end
```

When you try to update the diagonal with "5.6" you will see a flash error:

```text
Diagonal must be an integer.
```

But if you use your own custom popup, you can show messages with JS.

### Can I perform an action only on selected items?

The standard index page of a resource with `batch_action` enabled has a selectable column.

If you have checked some items and perform any collection action, the handler will take care of it. If you write
custom actions, you should do it like this:

```ruby
scoped_collection_action :do_something do
  scoped_collection_records.find_each do |record|
    record.update(name: 'x')
  end
end
```

## License

Released under the [MIT License](LICENSE.txt).
