# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yample/version'

Gem::Specification.new do |gem|
  gem.name          = "yample"
  gem.version       = Yample::VERSION
  gem.authors       = ["kyoendo"]
  gem.email         = ["postagie@gmail.com"]
  gem.description   = %q{Build List & Item pages from YAML data with a template engine}
  gem.summary       = %q{Build List & Item pages from YAML data with a template engine}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>=1.9.3'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakefs'
  gem.add_dependency 'hashie'
  gem.add_dependency 'liquid'
end
