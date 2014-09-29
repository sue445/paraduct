require "paraduct/version"
require "paraduct/configuration"
require "paraduct/variable_converter"
require "paraduct/runner"

module Paraduct
  class << self
    def configuration
      Paraduct::Configuration.instance
    end
    alias :config :configuration
  end
end
