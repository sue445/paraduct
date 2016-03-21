module Paraduct
  require "pty"

  class Runner
    attr_reader :script, :params, :base_job_dir

    # @param args
    # @option args :script [String, Array<String>] script file, script(s)
    # @option args :params [Hash{String => String}] key is capitalized and value is quoted (ex. foo=1 => FOO="1" )
    # @option args :base_job_dir [String]
    def initialize(args={})
      @script       = args[:script]
      @params       = args[:params]
      @base_job_dir = args[:base_job_dir]
      @job_id       = args[:job_id]
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
      full_stdout = ""
      exit_status = nil

      PTY.spawn(command) do |stdin, stdout, pid|
        stdout.close_write
        stdin.sync = true

        begin
          stdin.each do |line|
            line.strip!
            logger.info line
            full_stdout << "#{line}\n"
          end
        rescue Errno::EIO
        ensure
          _, exit_status = Process.waitpid2(pid)
        end
      end

      raise Paraduct::Errors::ProcessError.new(full_stdout, exit_status) unless exit_status.success?

      full_stdout
    end
  end
end
