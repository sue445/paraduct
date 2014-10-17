module Paraduct
  class ParallelRunner
    # @param script            [String, Array<String>] script file, script(s)
    # @param product_variables [Array<Hash{String => String}>]
    # @return [Array<String>] stdout messages of each job
    def self.perform_all(script, product_variables)
      threads = []
      stdout_messages = []
      base_job_dir = Paraduct.config.work_dir
      FileUtils.mkdir_p(base_job_dir) unless base_job_dir.exist?

      puts <<-EOS
======================================================
START matrix test
      EOS
      product_variables.each do |params|
        puts "params: #{params}"
      end

      product_variables.each do |params|
        threads << Thread.new(base_job_dir, script, params) do |_base_job_dir, _script, _params|
          job_dir = setup_runner(_base_job_dir, _params)
          stdout =
            begin
              Paraduct::Runner.perform(_script, _params)
            rescue Paraduct::ProcessError => e
              e.message
            end

          puts <<-EOS
======================================================
params: #{_params}
job_dir: #{job_dir}

#{stdout}
          EOS

          stdout_messages << stdout
        end
      end
      threads.map(&:join)

      stdout_messages
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

    def self.setup_runner(base_job_dir, params)
      job_dir = Paraduct::Runner.parameterized_job_dir(base_job_dir, params)
      FileUtils.mkdir_p(job_dir) unless job_dir.exist?
      copy_recursive(Paraduct.config.root_dir, job_dir)
      Dir.chdir(job_dir)
      job_dir
    end
    private_class_method :setup_runner
  end
end
