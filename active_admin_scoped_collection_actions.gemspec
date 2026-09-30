# coding: utf-8
require File.expand_path('../lib/active_admin_scoped_collection_actions/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "active_admin_scoped_collection_actions"
  spec.version       = ActiveAdminScopedCollectionActions::VERSION
  spec.authors       = ["Gena M."]
  spec.email         = ["workgena@gmail.com"]

  spec.summary       = %q{scoped_collection actions extension for ActiveAdmin}
  spec.description   = %q{Plugin for ActiveAdmin. Provides batch Update and Delete for scoped_collection (Filters + Scope) across all pages.}
  spec.homepage      = "https://github.com/activeadmin-plugins/active_admin_scoped_collection_actions"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 3.1.0'

  # `screenshots/` is two README images — 284 KB, 99% of the published
  # gem, for pictures that render from GitHub and are never read from
  # the package. `.github/` is CI config. `vendor/` stays: that is the
  # shipped JS.
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|screenshots|\.github)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activeadmin", ">= 3.0", "< 4.0"
end
