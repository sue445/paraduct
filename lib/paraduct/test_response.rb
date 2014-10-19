module Paraduct
  class TestResponse
    attr_reader :jobs

    def initialize
      @jobs = []
    end

    delegate :push, to: :jobs, prefix: true

    def successful?
      @jobs.all?{ |result| result[:successful] }
    end

    def failure?
      !successful?
    end
  end
end
