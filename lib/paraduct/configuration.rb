module Paraduct
  require "singleton"
  require "yaml"

  class Configuration
    include Singleton

    # @return [Pathname]
    def variables
      config_data["variables"]
    end

    # @return [String, Array<String>]
    def script
      config_data["script"]
    end

    # @return [Integer]
    def max_threads
      config_data["max_threads"] || 4
    end

    # @return [Pathname]
    def work_dir
      _work_dir = config_data["work_dir"] || "tmp/paraduct_workspace"
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

    private

    def config_data
      @config_data ||= YAML.load_file(config_file)
    end
  end
end
