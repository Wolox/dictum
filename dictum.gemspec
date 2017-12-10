# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dictum/version'
require 'date'

Gem::Specification.new do |spec|
  spec.name          = 'dictum'
  spec.version       = Dictum::VERSION
  spec.authors       = ['Alejandro Bezdjian']
  spec.email         = 'alebezdjian@gmail.com'
  spec.date          = Date.today
  spec.summary       = 'Document your APIs.'
  spec.description   = 'Create automatic documentation of your API endpoints through your tests.'
  spec.platform      = Gem::Platform::RUBY
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec)/}) }
  spec.require_paths = ['lib']
  spec.homepage      = 'https://github.com/Wolox/dictum'
  spec.license       = 'MIT'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})

  spec.add_dependency 'biruda', '0.1.1'
  spec.add_dependency 'nokogiri', '>= 1.3.3'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'rake', '~> 12.0'

  spec.add_development_dependency 'bundler', '>= 1.3.0', '< 2.0'
  spec.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  spec.add_development_dependency 'byebug', '~> 8.0', '>= 8.0.0' if RUBY_VERSION >= '2.0.0'
  spec.add_development_dependency 'rubocop', '~> 0.48', '>= 0.48.0'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.0'
  spec.add_development_dependency 'simplecov'
end
