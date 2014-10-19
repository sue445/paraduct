describe Paraduct::CLI do
  subject { Paraduct::CLI.start(args) }

  let(:args){ [command] }

  describe "#test" do
    let(:command){ "test" }

    include_context :within_temp_work_dir

    context "successful test" do
      let(:script){ "./script/build_success.sh" }
      let(:product_variables) do
        [
          { "ruby" => "1.9.3", "database" => "mysql"     , "rails" => "3.2.0" },
          { "ruby" => "1.9.3", "database" => "mysql"     , "rails" => "4.0.0" },
          { "ruby" => "1.9.3", "database" => "mysql"     , "rails" => "4.1.0" },
          { "ruby" => "1.9.3", "database" => "postgresql", "rails" => "3.2.0" },
          { "ruby" => "1.9.3", "database" => "postgresql", "rails" => "4.0.0" },
          { "ruby" => "1.9.3", "database" => "postgresql", "rails" => "4.1.0" },
          { "ruby" => "2.0.0", "database" => "mysql"     , "rails" => "3.2.0" },
          { "ruby" => "2.0.0", "database" => "mysql"     , "rails" => "4.0.0" },
          { "ruby" => "2.0.0", "database" => "mysql"     , "rails" => "4.1.0" },
          { "ruby" => "2.0.0", "database" => "postgresql", "rails" => "3.2.0" },
          { "ruby" => "2.0.0", "database" => "postgresql", "rails" => "4.0.0" },
          { "ruby" => "2.0.0", "database" => "postgresql", "rails" => "4.1.0" },
          { "ruby" => "2.1.2", "database" => "mysql"     , "rails" => "3.2.0" },
          { "ruby" => "2.1.2", "database" => "mysql"     , "rails" => "4.0.0" },
          { "ruby" => "2.1.2", "database" => "mysql"     , "rails" => "4.1.0" },
          { "ruby" => "2.1.2", "database" => "postgresql", "rails" => "3.2.0" },
          { "ruby" => "2.1.2", "database" => "postgresql", "rails" => "4.0.0" },
          { "ruby" => "2.1.2", "database" => "postgresql", "rails" => "4.1.0" },
        ]
      end

      let(:test_response) do
        test_response = Paraduct::TestResponse.new
        test_response.jobs_push(successful: true)
        test_response
      end

      it "should call perform_all" do
        expect(Paraduct::ParallelRunner).to receive(:perform_all).with(script, product_variables){ test_response }
        subject
      end
    end

    context "failure test" do
      before do
        allow(Paraduct.config).to receive(:script)   { %q(exit ${STATUS}) }
        allow(Paraduct.config).to receive(:variables){ { status: [0, 1] } }
      end

      it { expect{ subject }.to raise_error Paraduct::TestFailureError }
    end
  end

  describe "#generate" do
    let(:command){ "generate" }

    include_context "uses temp dir"

    around do |example|
      Dir.chdir(temp_dir) do
        example.run
      end
    end

    before do
      # exercise
      subject
    end

    let(:generated_config_file){ temp_dir_path.join(".paraduct.yml") }

    it { expect(generated_config_file).to be_exist }
  end
end
