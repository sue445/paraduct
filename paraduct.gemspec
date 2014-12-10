# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paraduct/version'

Gem::Specification.new do |spec|
  spec.name          = "paraduct"
  spec.version       = Paraduct::VERSION
  spec.authors       = ["sue445"]
  spec.email         = ["sue445@sue445.net"]
  spec.summary       = %q{matrix test runner}
  spec.description   = %q{Paraduct(parallel + parameterize + product) is matrix test runner}
  spec.homepage      = "https://github.com/sue445/paraduct"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 4.0.0"
  spec.add_dependency "colorize"     , "~> 0.7.3"
  spec.add_dependency "rsync"        , "~> 1.0.9"
  spec.add_dependency "thor"         , "~> 0.19.1"
  spec.add_dependency "thread"       , "~> 0.1.4"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-retry"
  spec.add_development_dependency "rspec-temp_dir"
  spec.add_development_dependency "yard"
end
