require "active_support"
require "active_support/deprecation"
require "active_support/core_ext"
require "paraduct/version"
require "paraduct/configuration"
require "paraduct/variable_converter"
require "paraduct/runner"
require "paraduct/parallel_runner"

module Paraduct
  class << self
    def configuration
      Paraduct::Configuration.instance
    end
    alias :config :configuration
  end
end
