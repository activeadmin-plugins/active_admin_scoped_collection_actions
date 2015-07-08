# active_admin_scoped_collection_actions
Plugin for ActiveAdmin. Provides batch Update and Delete for scoped_collection (Filters + Scope) across all pages.


# Description

This gem give you ability to perform various batch action on any filtered(or scoped) resource. Action applyes to all elements across all pages. It is similar to ActiveAdmin batch action, but affects not only checked records. Usefull if you want to delete or update a lot of records in one click.

# Install

Add gem to you "Gemfile"

```ruby
gem 'active_admin_scoped_collection_actions', github: 'workgena/active_admin_scoped_collection_actions'
```

Then in linux console run:

```
bundle
```

Add following JS to and of app/assets/javascript/active_admin.js.coffee

```javascript
//= require active_admin_scoped_collection_actions
```

Also include CSS to app/assets/stylesheets/active_admin.css.scss

```
@import "active_admin_scoped_collection_actions";
```

# Usage

Usually you need two standart actions - Delete and Update.

For example you have resource Posts. And you want to have delete action. So you need add one line:

```
scoped_collection_action :batch_destroy
```

Example:

```ruby
ActiveAdmin.register Post do
 config.batch_actions = true

 scoped_collection_action :batch_destroy

  index do
    # ...
  end
end
```

Important thing. Go to you browser page Posts. And you would not see any changes. Now in you sidebar Filter - filter posts by one parametr(id for exmaple). Only after that you will se delete button. It will be in sidebar under Filters.

### Update action

So we have one action. And now you wish to have ability to apdate some fileds.

Example for Phone-resource

```ruby
  scoped_collection_action :batch_update, form: -> do
                                          { name: 'text',
                                            diagonal: 'text',
                                            manufactured_at: 'datepicker',
                                            vendor_id: Vendor.all.map { |region| [region.name, region.id] },
                                            has_3g: [['Yes', 't'], ['No', 'f']]
                                          }
                                        end
```

In this example Phone-model has fields:
 * name - simple varchar string field
 * diagonal - this is integer(of float) field
 * manufactured_at - this is datetime field
 * vendor_id - if an assotiation "belongs_to :vendor, class_name: 'Vendor', foreign_key: :vendir_id"
 # has_3g - boolean field

In scoped_collection_action, "form" is an Proce'd Hash. It defines what fields you want to be batch updateble. Has-Key is a fields name in database. Hash-Value is a type of HTML-input. But we support only "<input type=text>", "datepicer" and "selecbox". In general, this is enough. It you want something more complex - you can build you own forms.

# Custom Actions

Example. We have Phone resouce. With field ...
