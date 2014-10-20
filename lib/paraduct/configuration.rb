module Paraduct
  require "singleton"
  require "yaml"

  class Configuration
    include Singleton

    def initialize
      raise "not found .paraduct.yml" unless config_file.exist?
      @config = YAML.load_file(config_file)
    end

    # @return [Pathname]
    def variables
      @config["variables"]
    end

    # @return [String, Array<String>]
    def script
      @config["script"]
    end

    # @return [Integer]
    def max_threads
      @config["max_threads"] || 4
    end

    # @return [Pathname]
    def work_dir
      _work_dir = @config["work_dir"] || "tmp/paraduct_workspace"
      root_dir.join(_work_dir)
    end

    # @return [Pathname]
    def config_file
      root_dir.join(".paraduct.yml")
    end

    # @return [Pathname]
    def root_dir
      Pathname.pwd
    end
  end
end
