module Paraduct
  class TestResponse
    attr_reader :jobs

    def initialize
      @jobs = []
    end

    delegate :push, :count, to: :jobs, prefix: true

    def successful?
      @jobs.all?{ |result| result[:successful] }
    end

    def failure?
      !successful?
    end

    def detail_message
      all_count = @jobs.count
      successful_count = @jobs.select{ |result| result[:successful] }.count
      failure_count = all_count - successful_count

      message = "======================================================\n"

      if successful_count > 0
        message << "Passed:\n\n"
        @jobs.select{ |result| result[:successful] }.each_with_index do |result, i|
          message << "  #{i + 1}) #{result[:formatted_params]}\n"
        end
        message << "\n"
      end

      if failure_count > 0
        message << "Failures:\n\n"
        @jobs.select{ |result| !result[:successful] }.each_with_index do |result, i|
          message << "  #{i + 1}) #{result[:formatted_params]}\n"
        end
        message << "\n"
      end

      message << "#{all_count} jobs, #{failure_count} failures, #{successful_count} passed\n"

      message
    end
  end
end
