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

    def detail_message
      all_count = @jobs.count
      successful_count = @jobs.select{ |result| result[:successful] }.count
      failure_count = all_count - successful_count

      message = "======================================================\n"

      if failure_count > 0
        message << "Failures:\n\n"
        @jobs.select{ |result| !result[:successful] }.each_with_index do |result, i|
          formatted_params = result[:params].inject([]) { |array, (key, value)|
            array << "#{key}=#{value}"
            array
          }.join(", ")
          message << "  #{i+1}) #{formatted_params}\n"
        end
        message << "\n"
      end
      message << "#{all_count} jobs, #{failure_count} failures, #{successful_count} passed\n"

      message
    end
  end
end
