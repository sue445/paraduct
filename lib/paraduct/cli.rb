require 'paraduct'
require 'thor'

module Paraduct
  class CLI < Thor
    include Thor::Actions

    class_option :version, type: :boolean

    desc "version", "Show paraduct version"
    def version
      puts Paraduct::VERSION
    end
    default_task :version

    desc "test", "run matrix test"
    def test
      script = Paraduct.config.script
      raise "require script" if script.blank?

      variables = Paraduct.config.variables
      raise "require variables" if variables.blank?

      product_variables = Paraduct::VariableConverter.product(variables)
      product_variables = Paraduct::VariableConverter.reject(product_variables, Paraduct.config.exclude)

      test_response = Paraduct::ParallelRunner.perform_all(script, product_variables)
      Paraduct.logger.info test_response.detail_message
      raise Paraduct::Errors::TestFailureError if test_response.failure?
    end

    desc "generate", "generate .paraduct.yml"
    def generate
      template(".paraduct.yml")
      template(".paraduct_rsync_exclude.txt")
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), "templates"))
    end
  end
end
