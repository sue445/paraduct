# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "paraduct/version"

Gem::Specification.new do |spec|
  spec.name          = "paraduct"
  spec.version       = Paraduct::VERSION
  spec.authors       = ["sue445"]
  spec.email         = ["sue445@sue445.net"]
  spec.summary       = "matrix test runner"
  spec.description   = "Paraduct(parallel + parameterize + product) is matrix test runner"
  spec.homepage      = "https://github.com/sue445/paraduct"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "activesupport"
  spec.add_dependency "colorize"
  spec.add_dependency "rsync"
  spec.add_dependency "thor", ">= 0.19.0"
  spec.add_dependency "thread"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-temp_dir"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"
end
