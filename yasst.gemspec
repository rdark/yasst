# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yasst/version'

Gem::Specification.new do |spec|
  spec.name          = 'yasst'
  spec.version       = Yasst::VERSION
  spec.authors       = ['Richard Clark']
  spec.email         = ['richard@fohnet.co.uk']

  spec.summary       = 'Yet Another Secret Stashing Toolkit'
  spec.description   = 'Yasst is a toolset for managing encryption and ' \
    'decryption of secrets'
  spec.homepage      = 'https://github.com/rdark/yasst'
  spec.license       = 'MIT'

  spec.require_paths = ['lib']

  dir_exclude = Regexp.new(%r{^(test|spec|features|bin)/})
  file_exclude = %r{^(\.gitignore|\.travis|\.rubocop|\.rspec|Guardfile)}
  excludes = Regexp.union(dir_exclude,file_exclude)
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(excludes) }

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.36'
  spec.add_development_dependency 'guard', '~> 2.13.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.6.4'
  spec.add_development_dependency 'guard-rubocop', '~> 1.2.0'
end
