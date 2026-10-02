## ActiveAdmin Scoped Collection Actions 2.1.0 (October 02, 2026) ##

*   New action option `:confirm_submit` - turns the fields dialog into two steps, the second one replaces the
    fields with amount of affected records and the changes to be applied
*   New action option `:confirm_summary` - tells the user how many records the action affects
*   Form field can be defined as `{type: 'text', class: 'my-widget'}` to render input with own class
*   **The required Ruby version is now 3.3** — Ruby 3.1 and 3.2 are EOL; stay on 2.0.0 for those
*   Tested against Ruby 3.3, 3.4 and 4.0 with Rails 8.0 and 8.1; Rails 7.1/7.2 left the CI matrix but are not excluded by any constraint
*   The packaged gem ships only `lib`, `vendor`, `config` and the docs — no spec suite, no screenshots

## ActiveAdmin Scoped Collection Actions 2.0.0 (April 07, 2026) ##

*   compatibility with ActiveAdmin 3.5, including its jQuery UI dialog changes
*   fixed the Sprockets manifest error on Rails 8.0+
*   New action option `:if` to conditionally hide a collection action (@qoqa #48)
*   `:confirm` accepts a proc (@qoqa #47)
*   dropped EOL Ruby and Rails versions

## ActiveAdmin Scoped Collection Actions 1.0.1 (March 02, 2024) ##

*  compatibility with ActiveAdmin 3.x (@oskarpearson #43)

## ActiveAdmin Scoped Collection Actions 0.3.5 (November 22, 2017) ##

*   compatibility with Decorators, fix is intended for old ActiveAdmin (@Zamyatin-AA #30)

## ActiveAdmin Scoped Collection Actions 0.3.4 (August 19, 2017) ##

*   Swedish locale (@buren #27)

## ActiveAdmin Scoped Collection Actions 0.3.3 (July 17, 2017) ##

*   Fixed compatibility with Rails 5.1

## ActiveAdmin Scoped Collection Actions 0.3.2 (July 17, 2017) ##

*   Added I18n support.

    translations for English and Spanish (@cpfarher #25).

    *Christian Pfarher*

