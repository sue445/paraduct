require "active_support"
require "active_support/deprecation"
require "active_support/core_ext"
require "pathname"

module Paraduct
  autoload :Configuration    , 'paraduct/configuration'
  autoload :Errors           , 'paraduct/errors'
  autoload :ParallelRunner   , 'paraduct/parallel_runner'
  autoload :Runner           , 'paraduct/runner'
  autoload :SyncUtils        , 'paraduct/sync_utils'
  autoload :TestResponse     , 'paraduct/test_response'
  autoload :ThreadLogger     , 'paraduct/thread_logger'
  autoload :VariableConverter, 'paraduct/variable_converter'
  autoload :Version          , 'paraduct/version'

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
