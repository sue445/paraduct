module Paraduct
  class ParallelRunner
    def self.perform_all(script, product_variables)
      threads = []
      stdout_messages = []
      product_variables.each do |params|
        threads << Thread.new(script, params) do |_script, _params|
          begin
            stdout_messages << Paraduct::Runner.perform(_script, _params)
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
