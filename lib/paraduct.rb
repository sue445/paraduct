require "active_support"
require "active_support/deprecation"
require "active_support/core_ext"
require "pathname"
require 'paraduct/version'

module Paraduct
  autoload :ColoredLabelLogger, 'paraduct/colored_label_logger'
  autoload :Configuration     , 'paraduct/configuration'
  autoload :Errors            , 'paraduct/errors'
  autoload :ParallelRunner    , 'paraduct/parallel_runner'
  autoload :Runner            , 'paraduct/runner'
  autoload :SyncUtils         , 'paraduct/sync_utils'
  autoload :TestResponse      , 'paraduct/test_response'
  autoload :VariableConverter , 'paraduct/variable_converter'

  class << self
    def configuration
      Paraduct::Configuration.instance
    end
    alias :config :configuration

    def logger
      @logger ||= ActiveSupport::Logger.new(STDOUT)
    end
  end
end
