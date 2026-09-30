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

  # Whitelist, not a reject list: a new directory in the repo does not
  # reach consumers until it is named here. The reject form needs a new
  # pattern every time the repo grows one, and that is how 284 KB of README images under screenshots/
  # ended up published in the first place.
  # `vendor/` is the shipped JS; `exe/` matches the bindir below.
  spec.files         = `git ls-files -z -- lib app vendor config exe bin README.md LICENSE.txt CHANGELOG.md`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activeadmin", ">= 3.0", "< 4.0"
end
