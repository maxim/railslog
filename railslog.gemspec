# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "railslog/version"

Gem::Specification.new do |s|
  s.name        = "railslog"
  s.version     = Railslog::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Maxim Chernyak"]
  s.email       = ["max@bitsonnet.com"]
  s.homepage    = ""
  s.summary     = %q{A simple client for Rails CHANGELOG files stored on github.}
  s.description = %q{Provides a convenient API for accessing Rails CHANGELOG files.}

  s.rubyforge_project = "railslog"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'turn'
end
