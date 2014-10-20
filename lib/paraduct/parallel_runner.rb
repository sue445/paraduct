module Paraduct
  class ParallelRunner
    # run script with arguments
    # @param script            [String, Array<String>] script file, script(s)
    # @param product_variables [Array<Hash{String => String}>]
    # @return [Paraduct::TestResponse]
    def self.perform_all(script, product_variables)
      threads = []
      test_response = Paraduct::TestResponse.new
      base_job_dir = Paraduct.config.work_dir
      FileUtils.mkdir_p(base_job_dir) unless base_job_dir.exist?

      Paraduct.logger.info <<-EOS
======================================================
START matrix test
      EOS
      product_variables.each do |params|
        Paraduct.logger.info "params: #{params}"
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
          rescue Paraduct::Errors::ProcessError => e
            stdout = e.message
            successful = false
          end

          Paraduct.logger.info <<-EOS
======================================================
params:   #{_runner.formatted_params}
job_name: #{_runner.job_name}
job_dir:  #{_runner.job_dir}

#{stdout}
          EOS

          test_response.jobs_push(
            job_name:         _runner.job_name,
            params:           _runner.params,
            formatted_params: _runner.formatted_params,
            successful:       successful,
            stdout:           stdout,
          )
        end
      end
      threads.map(&:join)

      test_response
    end
  end
end
