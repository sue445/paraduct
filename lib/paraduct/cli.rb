require 'paraduct'

module Paraduct
  module CLI
    def self.start
      script = Paraduct.config.script
      raise "require script" if script.blank?

      variables = Paraduct.config.variables
      raise "require variables" if variables.blank?

      product_variables = Paraduct::VariableConverter.product(variables)
      Paraduct::ParallelRunner.perform_all(script, product_variables)
    end
  end
end
