require 'fileutils'

# Builds the ActiveAdmin 4 stylesheet of the dummy app, scanning the gem the
# way the README tells a host to, so the specs see the modal laid out and
# Flowbite's `hidden` class really hides it.
module Tailwind
  module_function

  def compile!
    aa_path = Gem.loaded_specs['activeadmin'].full_gem_path
    gem_path = File.expand_path('../..', __dir__)
    app_path = ENV['RAILS_ROOT']
    input = File.join(app_path, 'tmp/active_admin_tailwind.css')
    output = File.join(app_path, 'app/assets/stylesheets/active_admin.css')

    FileUtils.mkdir_p(File.dirname(input))
    File.write(input, <<~CSS)
      @import "tailwindcss";
      @plugin "#{aa_path}/plugin.js";
      @custom-variant dark (&:where(.dark, .dark *));
      @source "#{aa_path}/vendor/javascript/flowbite.js";
      @source "#{aa_path}/plugin.js";
      @source "#{aa_path}/app/views/**/*.{arb,erb,html,rb}";
      @source "#{aa_path}/lib/active_admin/**/*.rb";
      @source "#{app_path}/app/admin/**/*.rb";
      @source "#{gem_path}/app/javascript/**/*.js";
      @source "#{gem_path}/lib/**/*.rb";
    CSS

    cli = Gem.bin_path('tailwindcss-ruby', 'tailwindcss')
    system(cli, '-i', input, '-o', output, out: File::NULL, err: File::NULL) or raise 'tailwindcss failed'
  end
end
