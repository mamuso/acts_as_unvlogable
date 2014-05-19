# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_unvlogable/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_unvlogable"
  s.version     = ActsAsUnvlogable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Manuel Muñoz", "Fernando Blat", "Alberto Romero"]
  s.email       = ["mamuso@mamuso.net", "ferblape@gmail.com", "denegro@gmail.com"]
  s.homepage    = "https://github.com/mamuso/acts_as_unvlogable"
  s.summary     = %q{An easy way to include external video services in a rails app}
  s.description = %q{An easy way to include external video services in a rails app. This gem provides you wrappers for the most common video services, such as Youtube, Vimeo, Flickr, and so on...}

  s.rubyforge_project = "acts_as_unvlogable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_runtime_dependency("nokogiri")
  s.add_runtime_dependency("youtube_it")
end
