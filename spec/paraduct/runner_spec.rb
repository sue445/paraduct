describe Paraduct::Runner do
  describe "#perform" do
    subject{ Paraduct::Runner.perform(script, params) }

    let(:script) { "./script/build_success.sh" }
    let(:params) { { "ruby" => "1.9", "database" => "mysql" } }
    let(:command){ 'RUBY="1.9" DATABASE="mysql" ./script/build_success.sh' }

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
      let(:script){ "echo debug1" }

      it { should eq "debug1\n" }
    end

    context "with multiple commands" do
      let(:script){ ["echo debug1", "echo debug2"] }

      it { should eq "debug1\ndebug2\n" }
    end
  end
end
