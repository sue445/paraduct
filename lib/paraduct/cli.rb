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
    option :dry_run, type: :boolean, default: false
    def test
      script = Paraduct.config.script
      raise "require script" if script.blank?

      variables = Paraduct.config.variables
      raise "require variables" if variables.blank?

      product_variables = Paraduct::VariableConverter.product(variables)
      product_variables = Paraduct::VariableConverter.reject(product_variables, Paraduct.config.exclude)

      if options[:dry_run]
        product_variables.each do |params|
          runner = Paraduct::Runner.new(params: params)
          Paraduct.logger.info "[dry-run] params: #{runner.formatted_params}"
        end
      else
        after_script = Paraduct.config.after_script
        test_response = Paraduct::ParallelRunner.perform_all(script: script, after_script: after_script, product_variables: product_variables)
        Paraduct.logger.info test_response.detail_message
        raise Paraduct::Errors::TestFailureError if test_response.failure?
      end
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
