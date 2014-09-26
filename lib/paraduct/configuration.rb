module Paraduct
  require "singleton"

  class Configuration
    include Singleton

    def initialize
      @config = YAML.load_file(config_file)
    end

    def variables
      @config["variables"]
    end

    def config_file
      root_dir.join(".paraduct.yml")
    end

    def root_dir
      Pathname.pwd
    end
  end
end
