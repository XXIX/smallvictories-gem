# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smallvictories/version'

Gem::Specification.new do |spec|
  spec.name          = "smallvictories"
  spec.version       = SmallVictories::VERSION
  spec.authors       = ["Michael Dijkstra"]
  spec.email         = ["michael@xxix.co"]
  spec.summary       = "A command line utility for building websites."
  spec.description   = "Small Victories Ruby interface."
  spec.homepage      = "https://github.com/xxix/smallvictories-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['sv']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'autoprefixer-rails', '~> 6.0'
  spec.add_runtime_dependency 'coffee-script', '~> 2.4'
  spec.add_runtime_dependency 'guard', '~> 2.13'
  spec.add_runtime_dependency 'guard-livereload', '~> 2.5'
  spec.add_runtime_dependency 'listen', '~> 3.0'
  spec.add_runtime_dependency 'liquid', '~> 3.0'
  spec.add_runtime_dependency 'sassc', '~> 1.6'
  spec.add_runtime_dependency 'sprockets', '~> 3.4'
  spec.add_runtime_dependency 'uglifier', '~> 2.7'
  spec.add_runtime_dependency 'yui-compressor', '~> 0.12'
  spec.add_runtime_dependency 'closure-compiler', '~> 1.1'
  spec.add_runtime_dependency 'premailer', '~> 1.8'
  spec.add_runtime_dependency 'nokogiri', '~> 1.4'
  spec.add_runtime_dependency 'mime-types'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
