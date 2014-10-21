describe Paraduct::CLI do
  subject { Paraduct::CLI.start(args) }

  let(:args){ [command] }

  describe "#version" do
    %w(version --version).each do |_command|
      context "with #{_command}" do
        let(:command){ _command }

        it { expect{ subject }.to output("#{Paraduct::VERSION}\n").to_stdout }
      end
    end
  end

  describe "#test" do
    let(:command){ "test" }

    include_context :stub_configuration
    include_context :within_temp_dir

    context "successful test" do
      let(:config_data) do
        {
          script: "./script/build_success.sh",
          work_dir: "tmp/paraduct_workspace",
          variables: {
            ruby:     ["1.9.3", "2.0.0"],
            database: ["mysql", "postgresql"],
          },
        }
      end

      let(:script){ "./script/build_success.sh" }
      let(:product_variables) do
        [
          { "ruby" => "1.9.3", "database" => "mysql"      },
          { "ruby" => "1.9.3", "database" => "postgresql" },
          { "ruby" => "2.0.0", "database" => "mysql"      },
          { "ruby" => "2.0.0", "database" => "postgresql" },
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
      let(:config_data) do
        {
          script: %q(exit ${STATUS}),
          work_dir: "tmp/paraduct_workspace",
          variables: {
            status: [0, 1],
          },
        }
      end

      it { expect{ subject }.to raise_error Paraduct::Errors::TestFailureError }
    end
  end

  describe "#generate" do
    let(:command){ "generate" }

    include_context :within_temp_dir

    before do
      # exercise
      subject
    end

    %w(.paraduct.yml .paraduct_rsync_exclude.txt).each do |template_file|
      describe "whether copy #{template_file}" do
        let(:generated_config_file){ temp_dir_path.join(template_file) }

        it { expect(generated_config_file).to be_exist }
      end
    end
  end
end
