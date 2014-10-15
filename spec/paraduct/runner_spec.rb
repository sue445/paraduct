describe Paraduct::Runner do
  describe "#perform" do
    subject{ Paraduct::Runner.perform(script, params) }

    let(:script) { "./script/build_success.sh" }
    let(:params) { { "ruby" => "1.9", "database" => "mysql" } }
    let(:command){ 'export RUBY="1.9"; export DATABASE="mysql"; ./script/build_success.sh' }

    context "with mock system" do
      it "script is call with capitalized variable" do
        expect(Paraduct::Runner).to receive(:run_command).with(command).and_return("stdout")
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
        let(:script){ "./script/build_error.sh" }

        let(:stdout) do
          <<-EOS
RUBY=1.9
DATABASE=mysql

          EOS
        end

        it { expect{ subject }.to raise_error(Paraduct::ProcessError, stdout) }
      end
    end

    context "with single command" do
      let(:script){ 'echo RUBY=${RUBY}' }

      it { should eq "RUBY=1.9\n" }
    end

    context "with multiple commands" do
      let(:script){ ['echo RUBY=${RUBY}', 'echo DATABASE=${DATABASE}'] }

      it { should eq "RUBY=1.9\nDATABASE=mysql\n" }
    end
  end

  describe "#parameterized_job_dir" do
    subject{ Paraduct::Runner.parameterized_job_dir(base_job_dir, params) }

    let(:base_job_dir){ "/tmp/jobs" }
    let(:params)      { { "ruby" => "1.9", "database" => "mysql" } }

    it { should eq Pathname("/tmp/jobs/RUBY_1.9_DATABASE_mysql") }
  end
end
