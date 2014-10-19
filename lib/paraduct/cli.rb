require 'paraduct'
require 'thor'

module Paraduct
  class CLI < Thor
    include Thor::Actions

    desc "test", "run matrix test"
    def test
      script = Paraduct.config.script
      raise "require script" if script.blank?

      variables = Paraduct.config.variables
      raise "require variables" if variables.blank?

      product_variables = Paraduct::VariableConverter.product(variables)
      test_response = Paraduct::ParallelRunner.perform_all(script, product_variables)
      puts test_response.detail_message
      raise Paraduct::TestFailureError if test_response.failure?
    end

    desc "generate", "generate .paraduct.yml"
    def generate
      template(".paraduct.yml")
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), "templates"))
    end
  end
end
