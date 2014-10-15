module Paraduct
  class ParallelRunner
    # @param script            [String, Array<String>] script file, script(s)
    # @param product_variables [Array<Hash{String => String}>]
    def self.perform_all(script, product_variables)
      threads = []
      stdout_messages = []
      current_dir = Pathname.pwd
      base_job_dir = current_dir.join("jobs")
      base_job_dir.mkdir unless base_job_dir.exist?
      product_variables.each do |params|
        threads << Thread.new(base_job_dir, script, params) do |_base_job_dir, _script, _params|
          begin
            job_dir = Paraduct::Runner.parameterized_job_dir(_base_job_dir, _params)
            job_dir.mkdir unless job_dir.exist?
            copy_recursive(current_dir, job_dir)
            Dir.chdir(job_dir)
            stdout_messages << Paraduct::Runner.perform(_script, _params)
          rescue Paraduct::ProcessError => e
            stdout_messages << e.message
          end
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
  end
end
