module Paraduct
  require "thread/pool"

  class ParallelRunner
    # run script with arguments
    # @param script            [String, Array<String>] script file, script(s)
    # @param product_variables [Array<Hash{String => String}>]
    # @return [Paraduct::TestResponse]
    def self.perform_all(script, product_variables)
      test_response = Paraduct::TestResponse.new
      base_job_dir = Paraduct.config.work_dir
      FileUtils.mkdir_p(base_job_dir) unless base_job_dir.exist?

      Paraduct.logger.info <<-EOS
======================================================
START matrix test
      EOS
      product_variables.each do |params|
        Paraduct.logger.info "params: #{params.map{ |key, value| "#{key}=#{value}" }.join(", ")}"
      end

      pool = Thread.pool(Paraduct.config.max_threads)
      begin
        product_variables.each do |params|
          pool.process do
            runner = Paraduct::Runner.new(
              script:       script,
              params:       params,
              base_job_dir: base_job_dir,
            )

            runner.setup_dir
            begin
              stdout = runner.perform
              successful = true
            rescue Paraduct::Errors::ProcessError => e
              stdout = e.message
              successful = false
            end

            Paraduct.logger.info <<-EOS
======================================================
params:   #{runner.formatted_params}
job_name: #{runner.job_name}
job_dir:  #{runner.job_dir}

            #{stdout}
            EOS

            test_response.jobs_push(
              job_name:         runner.job_name,
              params:           runner.params,
              formatted_params: runner.formatted_params,
              successful:       successful,
              stdout:           stdout,
            )
          end
        end

      ensure
        pool.shutdown
      end

      test_response
    end
  end
end
