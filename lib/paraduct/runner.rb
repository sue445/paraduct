module Paraduct
  require "pty"

  class Runner
    attr_reader :params, :base_job_dir

    # @param params [Hash{String => String}] value is quoted (ex. FOO=1 => FOO="1" )
    # @param base_job_dir [String]
    # @param job_id [String]
    def initialize(params: nil, base_job_dir: nil, job_id: nil)
      @params       = params
      @base_job_dir = base_job_dir
      @job_id       = job_id
    end

    def setup_dir
      FileUtils.mkdir_p(job_dir) unless job_dir.exist?
      Paraduct::SyncUtils.copy_recursive(Paraduct.config.root_dir, job_dir)
      Dir.chdir(job_dir)
    end

    # run script with params
    # @param script [String, Array<String>] script file, script(s)
    # @return [String] stdout
    # @raise [Paraduct::Errors::ProcessError] command exited error status
    def perform(script)
      export_variables = @params.reverse_merge("PARADUCT_JOB_ID" => @job_id, "PARADUCT_JOB_NAME" => job_name)
      variable_string = export_variables.map{ |key, value| %(export #{key}="#{value}";) }.join(" ")

      Array.wrap(script).inject("") do |stdout, command|
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
        stdout_logger = Paraduct::ColoredLabelLogger.new(formatted_params)
        file_logger   = Logger.new(Pathname(@base_job_dir).join("#{job_name}.log"))
        @logger       = stdout_logger.extend(ActiveSupport::Logger.broadcast(file_logger))
      end

      @logger
    end

    private

    def run_command(command)
      full_stdout = ""
      exit_status = nil

      logger.info "run_command: #{command}"

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
