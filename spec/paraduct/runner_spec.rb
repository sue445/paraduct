describe Paraduct::Runner do
  describe "#perform" do
    subject{ Paraduct::Runner.perform(script_file, params) }

    let(:script_file){ "./script/build_success.sh" }
    let(:params)     { {"ruby" => "1.9", "database" => "mysql"} }

    context "with mock system" do
      it "script is call with capitalized variable" do
        expect(Paraduct::Runner).to receive(:run_command).with('RUBY="1.9" DATABASE="mysql" ./script/build_success.sh').and_return("stdout")
        subject
      end
    end

    context "with real system" do
      around do |example|
        Dir.chdir(spec_dir) do
          example.run
        end
      end

      context "when success" do
        it { should match /RUBY=1.9/ }
        it { should match /DATABASE=mysql/ }
      end

      context "when error in script file" do
        let(:script_file){ "./script/build_error.sh" }

        let(:stdout) {
          <<-EOS
RUBY=1.9
DATABASE=mysql

          EOS
        }

        it { expect{ subject }.to raise_error(Paraduct::ProcessError, stdout) }
      end
    end
  end
end