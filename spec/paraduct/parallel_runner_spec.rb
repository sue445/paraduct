describe Paraduct::ParallelRunner do
  describe "#perform_all" do
    subject{ Paraduct::ParallelRunner.perform_all(script_file, product_variables) }

    let(:script_file){ "./script/build_success.sh" }
    let(:product_variables) do
      [
        { "ruby" => "1.9", "database" => "mysql" },
        { "ruby" => "2.0", "database" => "postgresql" },
      ]
    end

    around do |example|
      Dir.chdir(spec_dir) do
        example.run
      end
    end

    it { should include "RUBY=1.9\nDATABASE=mysql\n" }
    it { should include "RUBY=2.0\nDATABASE=postgresql\n" }
  end
end