module Paraduct
  require "colorize"
  require "open3"

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
      @color        = Paraduct::Runner.next_color
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
      variable_string = key_capitalized_params.map{ |key, value| %(export #{key}="#{value}";) }.join(" ")

      Array.wrap(@script).inject("") do |stdout, command|
        stdout << run_command("#{variable_string} #{command}")
        stdout
      end
    end

    def job_dir
      Pathname(@base_job_dir).join(job_name)
    end

    def job_name
      key_capitalized_params.map { |key, value| "#{key}_#{value}" }.join("_")
    end

    def key_capitalized_params
      self.class.capitalize_keys(@params)
    end

    def formatted_params
      @params.map{ |key, value| "#{key}=#{value}" }.join(", ")
    end

    def self.capitalize_keys(params)
      params.inject({}) do |res, (key, value)|
        res[key.upcase] = value
        res
      end
    end

    def self.next_color
      @@color_index ||= -1
      @@color_index = (@@color_index + 1) % colors.length
      colors[@@color_index]
    end

    def self.colors
      @@colors ||= %w( cyan yellow green magenta red blue light_cyan light_yellow
          light_green light_magenta light_red light_blue ).map(&:to_sym)
    end

    private
    def run_command(command)
      thread_id = Thread.current.object_id.to_s
      console_label = "[#{thread_id.colorize(@color)}]"

      lines = ""

      IO.popen(command) do |io|
        while line = io.gets
          Paraduct.logger.info "#{console_label} #{line.strip}"
          lines << line
        end
      end

      status = $?
      raise Paraduct::Errors::ProcessError.new(lines, status) unless status.success?

      lines
    end
  end
end
