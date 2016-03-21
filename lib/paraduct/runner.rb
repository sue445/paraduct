module Paraduct
  require "pty"
  require 'specinfra/core'

  class Runner
    attr_reader :script, :params, :base_job_dir

    # @param script [String, Array<String>] script file, script(s)
    # @param params [Hash{String => String}] value is quoted (ex. FOO=1 => FOO="1" )
    # @param base_job_dir [String]
    # @param job_id [String]
    def initialize(script: nil, params: nil, base_job_dir: nil, job_id: nil)
      @script       = script
      @params       = params
      @base_job_dir = base_job_dir
      @job_id       = job_id

      @backend = Specinfra::Backend::Exec.new
    end

    def setup_dir
      FileUtils.mkdir_p(job_dir) unless job_dir.exist?
      Paraduct::SyncUtils.copy_recursive(Paraduct.config.root_dir, job_dir)
      Dir.chdir(job_dir)
    end

    # run script with params
    # @return [String] stdout
    # @raise [Paraduct::Errors::ProcessError] command exited error status
    def perform
      export_variables = @params.reverse_merge("PARADUCT_JOB_ID" => @job_id, "PARADUCT_JOB_NAME" => job_name)
      variable_string = export_variables.map{ |key, value| %(export #{key}="#{value}";) }.join(" ")

      Array.wrap(@script).inject("") do |stdout, command|
        stdout << run_command("#{variable_string} #{command}")
        stdout
      end
    end

    def job_dir
      Pathname(@base_job_dir).join(job_name)
    end

    def job_name
      @params.map { |key, value| "#{key}_#{value}" }.join("_").gsub(%r([/ ]), "_")
    end

    def formatted_params
      @params.map{ |key, value| "#{key}=#{value}" }.join(", ")
    end

    def logger
      unless @logger
        stdout_logger = Paraduct::ColoredLabelLogger.new(object_id)
        file_logger   = Logger.new(Pathname(@base_job_dir).join("#{job_name}.log"))
        @logger       = stdout_logger.extend(ActiveSupport::Logger.broadcast(file_logger))
      end

      @logger
    end

    private

    def run_command(command)
      command_result = @backend.run_command(command)

      full_stdout = ""
      command_result.stdout.each_line do |line|
        line = line.strip
        logger.info line
        full_stdout << "#{line}\n"
      end
      command_result.stderr.each_line do |line|
        line = line.strip
        logger.info line
        full_stdout << "#{line}\n"
      end
      raise Paraduct::Errors::ProcessError.new(full_stdout, command_result.exit_status) if command_result.failure?

      full_stdout
    end
  end
end
