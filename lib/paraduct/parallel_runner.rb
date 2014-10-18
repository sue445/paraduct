module Paraduct
  class ParallelRunner
    # run script with arguments
    # @param script            [String, Array<String>] script file, script(s)
    # @param product_variables [Array<Hash{String => String}>]
    # @return [Array<Hash>] test response of each job
    def self.perform_all(script, product_variables)
      threads = []
      test_responses = []
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
        runner = Paraduct::Runner.new(
          script:       script,
          params:       params,
          base_job_dir: base_job_dir,
        )
        threads << Thread.new(runner) do |_runner|
          _runner.setup_dir
          begin
            stdout = _runner.perform
            successful = true
          rescue Paraduct::ProcessError => e
            stdout = e.message
            successful = false
          end

          puts <<-EOS
======================================================
params:   #{_runner.params}
job_name: #{_runner.job_name}
job_dir:  #{_runner.job_dir}

#{stdout}
          EOS

          test_responses << {
            job_name:   _runner.job_name,
            successful: successful,
            stdout:     stdout,
          }
        end
      end
      threads.map(&:join)

      test_responses
    end
  end
end
