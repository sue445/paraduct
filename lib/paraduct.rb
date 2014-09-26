require "paraduct/version"
require "paraduct/configuration"
require "paraduct/tester"

module Paraduct
  class << self
    def configuration
      Paraduct::Configuration.instance
    end
    alias :config :configuration
  end
end
