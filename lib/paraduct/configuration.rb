module Paraduct
  require "singleton"
  require "yaml"

  class Configuration
    include Singleton

    # @return [Pathname]
    def variables
      config_data[:variables]
    end

    # @return [String, Array<String>]
    def script
      config_data[:script]
    end

    # @return [Integer]
    def max_threads
      config_data[:max_threads] || 4
    end

    def rsync_option
      config_data[:rsync_option] || {}
    end

    def exclude
      config_data[:exclude] || []
    end

    # @return [Pathname]
    def work_dir
      config_data[:work_dir]
    end

    def base_job_dir
      if work_dir.blank?
        root_dir
      else
        root_dir.join(work_dir)
      end
    end

    def enable_rsync?
      !work_dir.blank?
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
      @config_data ||= YAML.load_file(config_file).with_indifferent_access
    end
  end
end
