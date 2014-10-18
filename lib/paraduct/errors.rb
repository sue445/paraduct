module Paraduct
  class TestFailureError < StandardError; end

  class ProcessError < StandardError
    attr_reader :status

    # @param message [String] stdout and stderr
    # @param status  [Process::Status]
    def initialize(message, status)
      super(message)
      @status = status
    end
  end
end
