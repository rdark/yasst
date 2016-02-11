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
  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(TODO|test|spec|features)/})
  }
  # ensure gem is built out of versioned files
  spec.executables = `git ls-files -- bin/*`.split("\n").map { |f|
    File.basename(f)
  }

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.36'
  spec.add_development_dependency 'guard', '~> 2.13.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.6.4'
  spec.add_development_dependency 'guard-rubocop', '~> 1.2.0'
end
