# Rails template to build the sample app for specs

activeadmin = Gem.loaded_specs['activeadmin']
aa_v4 = activeadmin.version >= Gem::Version.new('4.0.0.beta1')

unless aa_v4
  # Ensure Sprockets manifest exists (Rails 8.0+ no longer generates it)
  FileUtils.mkdir_p("app/assets/config")
  File.write("app/assets/config/manifest.js", "//= link_tree ../images\n")
end

generate :model, 'author name:string{10}:uniq last_name:string birthday:date --force'
generate :model, 'post title:string:uniq body:text author:references --force'

#Add validation
inject_into_file "app/models/author.rb", "  validates_presence_of :name\n  validates_uniqueness_of :last_name\n", after: "ApplicationRecord\n"
inject_into_file "app/models/post.rb", "  validates_presence_of :author\n", after: ":author\n"

# Add ransackable_attributes
inject_into_file "app/models/author.rb",
  "  def self.ransackable_attributes(auth_object = nil)\n" \
  "    [\"name\", \"last_name\", \"birthday\", \"created_at\", \"updated_at\"]\n" \
  "  end\n" \
  "  def self.ransackable_associations(auth_object = nil)\n" \
  "    []\n" \
  "  end\n",
  after: "ApplicationRecord\n"

inject_into_file "app/models/post.rb",
  "  def self.ransackable_attributes(auth_object = nil)\n" \
  "    [\"title\", \"body\", \"author_id\", \"created_at\", \"updated_at\"]\n" \
  "  end\n" \
  "  def self.ransackable_associations(auth_object = nil)\n" \
  "    [\"author\"]\n" \
  "  end\n",
  after: "ApplicationRecord\n"

# Add our local Active Admin to the load path (Rails 7.1+)
gsub_file "config/environment.rb",
  'require_relative "application"',
  "require_relative \"application\"\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'
generate :'decorator Author'

# Install active_admin_scoped_collection_actions assets
if aa_v4
  # spec_helper compiles Tailwind into active_admin.css before the suite.
  remove_file "app/assets/stylesheets/active_admin.css"
  remove_file "tailwind-active_admin.config.js"
  create_file "config/importmap.rb", ""

  # How the README tells a host without javascript_modules to load the module.
  html_head = File.read(File.join(activeadmin.full_gem_path, "app/views/active_admin/_html_head.html.erb"))
  create_file "app/views/active_admin/_html_head.html.erb",
    html_head + "<%= javascript_import_module_tag \"active_admin_scoped_collection_actions\" %>\n"
else
  inject_into_file "app/assets/stylesheets/active_admin.scss",
                   "@import \"active_admin_scoped_collection_actions\";\n",
                   after: "@import \"active_admin/base\";\n"

  inject_into_file "app/assets/javascripts/active_admin.js",
                  "//= require active_admin_scoped_collection_actions\n",
                  after: "//= require active_admin/base\n"
end

run "rm -rf test"
route "root :to => 'admin/dashboard#index'"
rake "db:migrate"

# Remove Gemfile last so rake/route/generate work during template
run "rm -f Gemfile Gemfile.lock"
