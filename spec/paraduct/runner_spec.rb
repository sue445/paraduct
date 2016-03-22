describe Paraduct::Runner do
  let(:runner) do
    Paraduct::Runner.new(
      params:       params,
      base_job_dir: base_job_dir,
      job_id:       job_id
    )
  end

  include_context "uses temp dir"

  let(:base_job_dir) { temp_dir }
  let(:params)      { {} }
  let(:job_id)      { 1 }

  describe "#perform" do
    subject { runner.perform(script) }

    let(:script) { "./script/build_success.sh" }
    let(:params) { { "RUBY" => "1.9", "DATABASE" => "mysql" } }
    let(:command) { 'export PARADUCT_JOB_ID="1"; export PARADUCT_JOB_NAME="RUBY_1.9_DATABASE_mysql"; export RUBY="1.9"; export DATABASE="mysql"; ./script/build_success.sh' }

    context "with mock system" do
      it "script is call with capitalized variable" do
        expect(runner).to receive(:run_command).with(command).and_return("stdout")
        subject
      end
    end

    context "with real system" do
      include_context :within_spec_dir

      context "when success" do
        it { should match /RUBY=1.9/ }
        it { should match /DATABASE=mysql/ }
      end

      context "when error in script file" do
        let(:script) { "./script/build_error.sh" }

        let(:stdout) do
          <<-EOS
RUBY=1.9
DATABASE=mysql
          EOS
        end

        it { expect { subject }.to raise_error(Paraduct::Errors::ProcessError, stdout) }
      end
    end

    context "with single command" do
      let(:script) { "echo RUBY=${RUBY}" }

      it { should eq "RUBY=1.9\n" }
    end

    context "with multiple commands" do
      let(:script) { ["echo RUBY=${RUBY}", "echo DATABASE=${DATABASE}"] }

      it { should eq "RUBY=1.9\nDATABASE=mysql\n" }
    end
  end

  describe "#job_dir" do
    subject { runner.job_dir }

    let(:params) { { "RUBY" => "1.9", "DATABASE" => "mysql" } }

    it { should eq temp_dir_path.join("RUBY_1.9_DATABASE_mysql") }
  end

  describe "#formatted_params" do
    subject { runner.formatted_params }

    let(:params) { { "RUBY" => "1.9", "DATABASE" => "mysql" } }

    it { should eq "RUBY=1.9, DATABASE=mysql" }
  end

  describe "#job_name" do
    subject { runner.job_name }

    context "basic case" do
      let(:params) { { "RUBY" => "1.9", "DATABASE" => "mysql" } }

      it { should eq "RUBY_1.9_DATABASE_mysql" }
    end

    context "containing slash" do
      let(:params) { { "RUBY" => "1.9", "GEMFILE" => "gemfiles/rails3_2.gemfile" } }

      it { should eq "RUBY_1.9_GEMFILE_gemfiles_rails3_2.gemfile" }
    end
  end
end
