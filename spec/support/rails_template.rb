# Rails template to build the sample app for specs

generate :model, 'author name:string{10}:uniq last_name:string birthday:date'
generate :model, 'post title:string:uniq body:text author:references'

#Add validation
inject_into_file "app/models/author.rb", "  validates_presence_of :name\n  validates_uniqueness_of :last_name\n", after: "ApplicationRecord\n"
inject_into_file "app/models/post.rb", "  validates_presence_of :author\n", after: ":author\n"

# Add ransackable_attributes
inject_into_file "app/models/author.rb",
  "  def self.ransackable_attributes(auth_object = nil)\n" \
  "    [\"name\", \"last_name\", \"birthday\"]\n" \
  "  end\n",
  after: "ApplicationRecord\n"

inject_into_file "app/models/post.rb",
  "  def self.ransackable_attributes(auth_object = nil)\n" \
  "    [\"title\", \"body\", \"author_id\"]\n" \
  "  end\n" \
  "  def self.ransackable_associations(auth_object = nil)\n" \
  "    [\"author\"]\n" \
  "  end\n",
  after: "ApplicationRecord\n"

# Configure default_url_options in test environment
inject_into_file "config/environments/test.rb", "  config.action_mailer.default_url_options = { :host => 'example.com' }\n", after: "config.cache_classes = true\n"

# Add our local Active Admin to the load path
inject_into_file "config/environment.rb",
                 "\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n",
                 after: "require File.expand_path('../application', __FILE__)"

run "rm Gemfile"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'
generate :'decorator Author'

# Install active_admin_date_time_datetimepicker assets
inject_into_file "app/assets/stylesheets/active_admin.scss",
                 "@import \"active_admin_scoped_collection_actions\";\n",
                 after: "@import \"active_admin/base\";\n"

if File.file?("app/assets/javascripts/active_admin.js.coffee")
  inject_into_file "app/assets/javascripts/active_admin.js.coffee",
                   "#= require active_admin_scoped_collection_actions\n",
                   after: "#= require active_admin/base\n"
else
  inject_into_file "app/assets/javascripts/active_admin.js",
                  "//= require active_admin_scoped_collection_actions\n",
                  after: "//= require active_admin/base\n"
end

run "rm -r test"
run "rm -r spec"

route "root :to => 'admin/dashboard#index'"

rake "db:migrate"
