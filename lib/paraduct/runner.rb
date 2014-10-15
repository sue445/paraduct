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
    # @param script [String, Array<String>] script file, script(s)
    # @param params [Hash{String => String}] key is capitalized and value is quoted (ex. foo=1 => FOO="1" )
    # @return [String] stdout
    # @raise [Paraduct::ProcessError] command exited error status
    def self.perform(script, params)
      variable_string = capitalize_keys(params).map{ |key, value| %(export #{key}="#{value}";) }.join(" ")

      if script.is_a?(Enumerable)
        script.inject("") do |stdout, command|
          stdout << run_command("#{variable_string} #{command}")
          stdout
        end
      else
        run_command("#{variable_string} #{script}")
      end
    end

    def self.parameterized_job_dir(base_job_dir, params)
      dir_name = capitalize_keys(params).map{ |key, value| "#{key}_#{value}" }.join("_")
      Pathname(base_job_dir).join(dir_name)
    end

    def self.run_command(command)
      stdout, stderr, status = Open3.capture3(command)
      raise ProcessError.new("#{stdout}\n#{stderr}", status) unless status.success?
      stdout
    end
    private_class_method :run_command

    def self.capitalize_keys(params)
      params.inject({}) do |res, (key, value)|
        res[key.upcase] = value
        res
      end
    end
    private_class_method :capitalize_keys
  end
end
