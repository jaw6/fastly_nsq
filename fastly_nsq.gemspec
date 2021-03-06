# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastly_nsq/version'

Gem::Specification.new do |gem|
  gem.name          = 'fastly_nsq'
  gem.version       = FastlyNsq::VERSION
  gem.summary       = 'Fastly NSQ Adapter'
  gem.description   = "Helper classes for Fastly's NSQ Services"
  gem.license       = 'MIT'
  gem.authors       = ["Tommy O'Neil", 'Adarsh Pandit', 'Joshua Wehner', 'Lukas Eklund']
  gem.email         = 'tommy@fastly.com'
  gem.homepage      = 'https://github.com/fastly/fastly-nsq'

  gem.files         = `git ls-files`.split("\n")

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'awesome_print', '~> 1.6'
  gem.add_development_dependency 'bundler', '~> 1.12'
  gem.add_development_dependency 'bundler-audit', '~> 0.5.0'
  gem.add_development_dependency 'overcommit', '~> 0.32.0'
  gem.add_development_dependency 'pry-byebug', '~> 3.3'
  gem.add_development_dependency 'rake', '~> 11.1.2'
  gem.add_development_dependency 'rdoc', '~> 4.2.2'
  gem.add_development_dependency 'rspec', '~> 3.4.0'
  gem.add_development_dependency 'rubocop', '~> 0.39.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.add_dependency 'nsq-ruby', '~> 2.0', '>= 2.0.5'
end
