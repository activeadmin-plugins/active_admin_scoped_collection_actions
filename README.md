# ActiveAdmin Scoped Collection Actions
Plugin for ActiveAdmin. Provides batch Update and Delete for scoped_collection (Filters + Scope) across all pages.


# Description

This gem give you ability to perform various batch actions on any filtered(or scoped) resource. Action applies to all elements across all pages. It is similar to ActiveAdmin batch action, but affects not only checked records. Usefull if you want to delete or update a lot of records in one click.

# Install

Add gem to you "Gemfile"

```ruby
gem 'active_admin_scoped_collection_actions', github: 'workgena/active_admin_scoped_collection_actions'
```

Then in linux console run:

```
$ bundle
```

Add the following line at the end of "app/assets/javascript/active_admin.js.coffee"

```javascript
//= require active_admin_scoped_collection_actions
```

Also include CSS in "app/assets/stylesheets/active_admin.css.scss"

```css
@import "active_admin_scoped_collection_actions";
```

# Usage

Usually you need two standart actions: Delete and Update.

For example you have resource Posts. And you want to have delete action. So you one line:

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

Important thing. Go to you browser page Posts. And you would not see any changes. Now in sidebar Filters - filter posts by any parameter. Only after that you will se delete button. It will be in sidebar under Filters.

### Update action

Update is second standart action. It is more complex. It has "form" hash wrapped in Proc.

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

In this example Phone-model has fields:
 * name - varchar string
 * diagonal - integer(of float)
 * manufactured_at - datetime
 * vendor_id - association "belongs_to :vendor, class_name: 'Vendor', foreign_key: :vendor_id"
 * has_3g - boolean

Parameter "form" is an Hash wrapped in Proc. It defines what fields you want to be able to update. Hash-Key is a fields name in database. Hash-Value is a type of HTML-input. Now we only support ""text", "datepicer" and "selecbox". It you want something more complex - you can build you own forms.

# Custom Actions

Example. We have Phone resource. It has field "manufactured_at". And we need action which will erase this date.

In ActiveAdmin resource

```ruby
ActiveAdmin.register Phone do
  config.batch_actions = true

  scoped_collection_action :erase_date do
    batch_action_collection.update_all(manufactured_at: nil)
  end

  index do
    # ...
  end
end
```

This simple code will create new button in sidebar "Erase date". When user press it hi will see confirm message "Are you sure?". If click OK - than page reloads and erase date in all filtered records.


# Details and Settings


### Why I don't see Sidebar with Collection Actions.

Sidebar visibility by default depends on several things.

First you must set

```ruby
config.batch_actions = true
```

Inside of thi Gem we use "batch_actions". So without tem Collection Actions don't work.

```ruby
scoped_collection_action :something_here
```

You resource should have some collection actions. It it don't have any - sidebar will not render.

And the last one. By default we dont allow perform actions on all the records. We want protect you from accidental deleting.
Sidebar with buttons will appear only when you Filtering or Scoping resource items.

But, if you prefer, you can allow your admins to perform Collection Actions over all the resource records.
In you resource set configuration

```ruby
config.scoped_collection_actions_on_all = true
```

### How can I rename button ?

Every scoped_collection_action has option :title. Example:

```ruby
  scoped_collection_action :erase_date, title: 'Nullify' do
    batch_action_collection.update_all(manufactured_at: nil)
  end
```


### How can I modify modal dialog title?

Similar to button title. User option :confirm

```ruby
  scoped_collection_action :scoped_collection_destroy, confirm: 'Delete all phones?'
```


### Can I replace you pop-up form with my own?

Yes. But also you must take care of required parameters passed to server.


```ruby
  scoped_collection_action :my_pop_action, class: 'my_popup'
```

Now in HTML page, you have button:

```html
  <button class="my_popup" data="{&quot;auth_token&quot;:&quot;2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0=&quot;,&quot;batch_action&quot;:&quot;my_pop_action&quot;,&quot;confirm&quot;:&quot;Are you sure?&quot;}">My pop action</button>
```

But without handler. Click on the button do nothing.

You can render you form in any way you want.
It can be some popup(Fancybox, Simplemodal, etc.), or some inline collapsible form.
It can even be a complex full-page.

One thin is important. How you will send data to server. Generally it should be:


POST request on url

/admin/collection_path/batch_action

with GET params identical to current scoped/filtered collection

The easiest way to get it is:

```javascript
url = window.location.pathname + '/batch_action' + window.location.search
```

And Request body paras should be like:

changes[manufactured_at] = "2015-07-21 18:11"
changes[diagoanl] = "7"
authenticity_token = "2a+KLu5u9McQENspCiep0DGZI6D09fCVXAN9inrwRG0="
batch_action = "my_pop_action"

authenticity_token and batch_action you can get from data-attribute of the Button.


Example in JavaScript

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

### How notify user about success and error operations ?

We recommend to use Rails Flash messages.

Example with Erasing phone diagonal. In this case you Phone-model has validation:

```ruby
  class Phone < ActiveRecord::Base
    validates :diagonal, numericality: { only_integer: true }
  end
```

```ruby
  scoped_collection_action :change_diagonal, form: { diagonal: 'text' }  do
    errors = []
    batch_action_collection.find_each do |record|
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

But if you use you custom popup, you can show messages with JS.