describe Paraduct::ParallelRunner do
  describe "#perform_all" do
    subject{ Paraduct::ParallelRunner.perform_all(script, product_variables) }

    include_context "uses temp dir"

    around do |example|
      Dir.chdir(temp_dir) do
        FileUtils.cp_r(spec_dir.join("script"), Dir.pwd)
        example.run
      end
    end

    describe "with script file test" do
      let(:script){ "./script/build_success.sh" }
      let(:product_variables) do
        [
          { "ruby" => "1.9", "database" => "mysql" },
          { "ruby" => "2.0", "database" => "postgresql" },
        ]
      end

      it { should include "RUBY=1.9\nDATABASE=mysql\n" }
      it { should include "RUBY=2.0\nDATABASE=postgresql\n" }
    end

    describe "without script file test" do
      let(:script){ %q(echo "RUBY=${RUBY} DATABASE=${DATABASE}") }
      let(:product_variables) do
        [
          { "ruby" => "1.9", "database" => "mysql" },
          { "ruby" => "2.0", "database" => "postgresql" },
        ]
      end

      it { should include "RUBY=1.9 DATABASE=mysql\n" }
      it { should include "RUBY=2.0 DATABASE=postgresql\n" }
    end
  end
end
