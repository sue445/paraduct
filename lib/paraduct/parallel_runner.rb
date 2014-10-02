module Paraduct
  class ParallelRunner
    def self.perform_all(script_file, product_variables)
      threads = []
      stdout_messages = []
      product_variables.each do |params|
        threads << Thread.new(script_file, params) do |_script_file, _params|
          begin
            stdout_messages << Paraduct::Runner.perform(_script_file, _params)
          rescue ProcessError => e
            stdout_messages << e.message
          end
        end
      end
      threads.map(&:join)

      stdout_messages
    end
  end
end
