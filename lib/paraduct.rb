require "active_support"
require "active_support/deprecation"
require "active_support/core_ext"
require "paraduct/version"
require "paraduct/configuration"
require "paraduct/variable_converter"
require "paraduct/runner"
require "paraduct/parallel_runner"
require "paraduct/errors"
require "pathname"

module Paraduct
  class << self
    def configuration
      Paraduct::Configuration.instance
    end
    alias :config :configuration
  end
end
