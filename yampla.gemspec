# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yampla/version'

Gem::Specification.new do |gem|
  gem.name          = "yampla"
  gem.version       = Yampla::VERSION
  gem.authors       = ["kyoendo"]
  gem.email         = ["postagie@gmail.com"]
  gem.description   = %q{Build List & Item pages from YAML data with a template engine}
  gem.summary       = %q{Build List & Item pages from YAML data with a template engine}
  gem.homepage      = "https://github.com/melborne/yampla"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>=1.9.3'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakefs'
  gem.add_dependency 'hashie'
  gem.add_dependency 'liquid'
  gem.add_dependency 'trollop'
end
