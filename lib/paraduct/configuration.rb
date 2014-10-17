module Paraduct
  require "singleton"
  require "yaml"

  class Configuration
    include Singleton

    def initialize
      @config = YAML.load_file(config_file)
    end

    def variables
      @config["variables"]
    end

    def script
      @config["script"]
    end

    def work_dir
      _work_dir = @config["work_dir"] || "tmp/paraduct_workspace"
      root_dir.join(_work_dir)
    end

    def config_file
      root_dir.join(".paraduct.yml")
    end

    def root_dir
      Pathname.pwd
    end
  end
end
