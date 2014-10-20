module Paraduct
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
    end

    def setup_dir
      FileUtils.mkdir_p(job_dir) unless job_dir.exist?
      self.class.copy_recursive(Paraduct.config.root_dir, job_dir)
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

    # @param source_dir      [Pathname]
    # @param destination_dir [Pathname]
    def self.copy_recursive(source_dir, destination_dir)
      FileUtils.mkdir_p(destination_dir)
      source_dir.children.each do |source_child_dir|
        begin
          FileUtils.cp_r(source_child_dir, destination_dir)
        rescue ArgumentError => e
          # TODO: refactoring
          raise unless e.message =~ /^cannot copy directory .+ to itself /
        end
      end
    end

    def self.capitalize_keys(params)
      params.inject({}) do |res, (key, value)|
        res[key.upcase] = value
        res
      end
    end

    private
    def run_command(command)
      stdout, stderr, status = Open3.capture3(command)
      raise Paraduct::Errors::ProcessError.new("#{stdout}\n#{stderr}", status) unless status.success?
      stdout
    end
  end
end
