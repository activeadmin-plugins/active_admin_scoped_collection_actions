[![Build Status](https://github.com/activeadmin-plugins/active_admin_scoped_collection_actions/actions/workflows/ci.yml/badge.svg)](https://github.com/activeadmin-plugins/active_admin_scoped_collection_actions/actions/workflows/ci.yml)
![Coverage](https://img.shields.io/endpoint?url=https://activeadmin-plugins.github.io/active_admin_scoped_collection_actions/badge.json)


# ActiveAdmin Scoped Collection Actions
Plugin for ActiveAdmin. Provides batch Update and Delete for scoped_collection (Filters + Scope) across all pages.

![Step 1](/screenshots/sidebar.png)

![Step 1](/screenshots/pupup.png)


# Description

This gem give you ability to perform various batch actions on any filtered (or scoped) resource. Action applies to all records across all pages. It is similar to ActiveAdmin batch action, but affects all filtered records. This is usefull if you want to delete or update a lot of records in one click.

# Install

Add this line to your application's Gemfile:

```ruby
# last version
gem 'active_admin_scoped_collection_actions'
# master branch
gem 'active_admin_scoped_collection_actions', github: 'activeadmin-plugins/active_admin_scoped_collection_actions'
```

And then execute:

```
$ bundle
```

Add the following line at the end of "app/assets/javascript/active_admin.js":

```javascript
//= require active_admin_scoped_collection_actions
```

Also include CSS in "app/assets/stylesheets/active_admin.css.scss"

```css
@import "active_admin_scoped_collection_actions";
```

# Usage

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

**Important**: Visit Posts page with your browser and you will see no changes. Now, perform any filter with the Filters sidebar. Only after you filter will you see a delete button. It will be in sidebar under Filters.

### Update action

Update is second standard action and is more complex. It has "form" hash wrapped in Proc:

```ruby
  scoped_collection_action :scoped_collection_update, form: -> do
                                         { name: 'text',
                                            diagonal: 'text',
                                            manufactured_at: 'datepicker',
                                            vendor_id: Vendor.all.map { |region| [region.name, region.id] },
                                            has_3g: [['Yes', 't'], ['No', 'f']]
                                          }
                                        end
```

In this example Phone model has fields:
 * name - varchar string
 * diagonal - integer(of float)
 * manufactured_at - datetime
 * vendor_id - association "belongs_to :vendor, class_name: 'Vendor', foreign_key: :vendor_id"
 * has_3g - boolean

Parameter "form" is a proc object which returns Hash. It defines what fields you want to be able to update. Hash keys are  column names in database. Hash values are a types of HTML inputs. We support only "text", "datepicker" and "selectbox". If you want something more complex - you can build your own forms.

A field value can also be a Hash `{type: 'text', class: 'my-widget'}`. Such field is rendered as a plain input with your own
class on it, so you can turn it into any widget(datetime picker, autocomplete, etc.) with your own JavaScript. The dialog
triggers `mass_update_modal_dialog:after_open` event on `body` with the form as an argument, this is the place to initialize
your widgets:

```javascript
  $(document).on('mass_update_modal_dialog:after_open', function (event, form) {
    $(form).find('input.my-widget').myWidget();
  });
```

# Custom Actions

Example: We have Phone resource and it has column "manufactured_at". We need an action which will erase this date.

In ActiveAdmin resource:

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

This simple code will create a new button "Erase date" in sidebar. After clicking this button, the user will see confirm message "Are you sure?". After confirming, all filtered records will be updated.


# Details and Settings


### Why I don't see Sidebar with Collection Actions.

Sidebar visibility by default depends on several things.

First you must set:

```ruby
config.batch_actions = true
```

Actually, inside of this Gem we use "batch_actions". So without them Collection Actions wouldn't work.

```ruby
scoped_collection_action :something_here
```

You resource should have some collection actions. If it doesn't have any, the sidebar will not appear.

By default we dont allow perform actions on **all** the records. We want protect you from accidental deleting.

Sidebar with buttons will appear only after you perform filtering or scopes on resource records.

And lastly you can manage sidebar visibility by resource config:

```ruby
# Always
config.scoped_collection_actions_if = -> { true }
# Only for scopes
config.scoped_collection_actions_if = -> { params[:scope] }
# etc.
```

You can also manage visibility of each action individually:

```ruby
scoped_collection_action :scoped_collection_destroy, if: proc { can? :destroy, Blog }
```

### Can I use my handler on update/delete action?

You can pass block to default actions update and delete.
And do custom redirect after it. Use `render` (location: 'something') instead of `redirect_to()`.

This example renders form which allows to change `name` field. And after it do redirect to dashboard page.

```ruby
  scoped_collection_action :scoped_collection_update,
                           form: -> {
                             {name: 'text'}
                           } do
    scoped_collection_records.update_all(name: params[:changes][:name])
    flash[:notice] = 'Name successfully changed.'
    render nothing: true, status: :no_content, location: admin_dashboard_path
  end
```


### How can I rename button?

Every scoped_collection_action has option `:title`.

Example:

```ruby
  scoped_collection_action :erase_date, title: 'Nullify' do
    scoped_collection_records.update_all(manufactured_at: nil)
  end
```


### How can I modify modal dialog title?

Similar to button title. Use option `:confirm`

```ruby
  scoped_collection_action :scoped_collection_destroy, confirm: 'Delete all phones?'
```


### How can I tell the user how many records are affected?

Option `:confirm_summary` adds a sentence with the amount of affected records to the dialog:

```ruby
  scoped_collection_action :scoped_collection_destroy, confirm_summary: true
```

```
Delete all?

You are going to delete 100500 record(s).

                                   [ OK ] [ Cancel ]
```

`true` uses the default text - `confirm_destroy_summary` locale key for `:scoped_collection_destroy` and
`confirm_action_summary` for any other action. Pass a String or a Proc to use your own text. `{count}` in the
text is replaced with the number.

The amount is requested when the dialog is opened, with the same filters, scope and checked records the action
itself will use, so it costs one extra COUNT query per opened dialog. Until it arrives the message is not
displayed at all - there is a spinner in its place and OK is disabled, so nothing can be confirmed before the
user sees what they confirm. Without `:confirm_summary` nothing is counted and nothing is requested.

Both options in one flow - an update action with `confirm_submit:` and the summary it shows, from the sidebar
button to the result:

![confirm_summary and confirm_submit](/screenshots/example_confirm_summary.png)

### How can I ask an extra confirmation before the form is submitted?

An action without a form is confirmed by the modal dialog itself - it has no fields and the user just presses OK.
An action with a form applies changes immediately after OK is pressed. Use option `:confirm_submit` to turn such
action into two steps - the second one replaces the fields with a summary of what is going to happen:

```ruby
  scoped_collection_action :scoped_collection_update,
                           confirm_submit: true,
                           form: -> { { body: 'text' } }
```

```
Are you sure?

You are going to update 100500 record(s) with:
  Body: Text here...
  Author_id: Jane

                                     [ OK ] [ Back ]
```

"Back" returns to the form with everything the user filled in still there. Only the fields the user checked are
listed, and when nothing is checked there is nothing to confirm - the action is performed right away. Text of
the sentence is `confirm_submit_summary` locale key, or `:confirm_summary` option when you set it.

```ruby
  scoped_collection_action :scoped_collection_update,
                           confirm_submit: true,
                           form: -> { { name: 'text' } }
```

`true` shows the default message ("Are you sure?"). Pass a String or a Proc to use your own:

```ruby
  scoped_collection_action :scoped_collection_update,
                           confirm_submit: 'Update all filtered phones?',
                           form: -> { { name: 'text' } }
```


### Can I replace you pop-up form with my own?

Yes. But also you must take care of mandatory parameters passed to the server.


```ruby
  scoped_collection_action :my_pop_action, class: 'my_popup'
```

Now in HTML page, you have button:

```html
  <button class="my_popup" data="{&quot;auth_token&quot;:&quot;2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0=&quot;,&quot;batch_action&quot;:&quot;my_pop_action&quot;,&quot;confirm&quot;:&quot;Are you sure?&quot;}">My pop action</button>
```

Without handler, clicking on the button does nothing.

You can render the form in any way you want:
  - It can be some popup(Fancybox, Simplemodal, etc.), or some inline collapsible form.
  - It can even be a separate full-page.

One thing is important - how you will send data to server. Generally it should be:

POST request

URL: /admin/collection_path/batch_action

with GET params identical to current page

The easiest way to get them is:

```javascript
url = window.location.pathname + '/batch_action' + window.location.search
```

And Request body params should be like:

```
changes[manufactured_at] = "2015-07-21 18:11"
changes[diagonal] = "7"
changes[some_filed_name]='new value'
authenticity_token = "2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0="
batch_action = "my_pop_action"
```

```authenticity_token``` and ```batch_action``` you can get from data-attribute of the Button.


Example in JavaScript:

```javascript
  url = window.location.pathname + '/batch_action' + window.location.search
  form_data = {
    changes: {"manufactured_at": "2015-07-21 18:11", "diagonal": "7"},
    collection_selection: [],
    authenticity_token: "2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0=",
    batch_action: "my_pop_action"
  }
  $.post(url, form_data).always () ->
    window.location.reload()
```

### How notify user about success and error operations?

We recommend using Rails Flash messages.

Example with updating phone diagonal attribute. In this case model Phone has validation:

```ruby
  class Phone < ActiveRecord::Base
    validates :diagonal, numericality: { only_integer: true }
  end
```

```ruby
  scoped_collection_action :change_diagonal, form: { diagonal: 'text' }  do
    errors = []
    scoped_collection_records.find_each do |record|
      errors << "#{record.errors.full_messages.join('. ')}" unless record.update(diagonal: params[:changes][:diagonal])
    end
    if errors.empty?
      flash[:notice] = 'Diagonal changed successfully'
    else
      flash[:error] = errors.join('. ')
    end
    render nothing: true, status: :no_content
  end
```

When you try to update diagonal with "5.6" you will see flash error:

```
Diagonal must be an integer.
```

But if you use your custom popup, you can show messages with JS.


### Can I perform action only on selected items?

Standard index-page of a resource with batch_action enabled has selectable column.

If you checked some items and parform any Collection Action, the handler will take care of it. If you write custom actions, you should do like this:

```ruby
  scoped_collection_action :do_something do
    scoped_collection_records.find_each do |record|
      record.update(name: 'x')
    end
  end
```
