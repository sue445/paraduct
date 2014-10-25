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

      pool = Thread.pool(Paraduct.config.max_threads)
      begin
        product_variables.each_with_index do |params, index|
          runner = Paraduct::Runner.new(
            script:       script,
            params:       params,
            base_job_dir: base_job_dir,
            job_id:       index + 1,
          )
          pool.process do
            runner.logger.info "[START] params: #{runner.formatted_params}"
            runner.setup_dir
            begin
              stdout = runner.perform
              successful = true
            rescue Paraduct::Errors::ProcessError => e
              runner.logger.error "exitstatus=#{e.status}, #{e.inspect}"
              stdout = e.message
              successful = false
            end

            runner.logger.info "[END]   params: #{runner.formatted_params}"

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

      raise Paraduct::Errors::DirtyExitError unless test_response.jobs_count == product_variables.count

      test_response
    end
  end
end
