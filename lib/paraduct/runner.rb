module Paraduct
  require "open3"

  class ProcessError < StandardError
    attr_reader :status

    # @param message [String] stdout and stderr
    # @param status  [Process::Status]
    def initialize(message, status)
      super(message)
      @status = status
    end
  end

  class Runner
    # run script with params
    # @param script_file [String]
    # @param params      [Hash{String => String}] key is capitalized and value is quoted (ex. foo=1 => FOO="1" )
    # @return [String] stdout
    # @raise [Paraduct::ProcessError] command exited error status
    def self.perform(script_file, params)
      capitalized_params = params.inject({}){|res, (key,value)|
        res[key.upcase] = value
        res
      }
      variable_string = capitalized_params.map{|key, value| %Q(#{key}="#{value}") }.join(" ")
      run_command("#{variable_string} #{script_file}")
    end

    def self.run_command(command)
      stdout, stderr, status = Open3.capture3(command)
      raise ProcessError.new("#{stdout}\n#{stderr}", status) unless status.success?
      stdout
    end
    private_class_method :run_command
  end
end
