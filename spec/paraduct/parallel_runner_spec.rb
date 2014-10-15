describe Paraduct::ParallelRunner do
  describe "#perform_all" do
    subject{ Paraduct::ParallelRunner.perform_all(script, product_variables) }

    include_context "uses temp dir"

    before do
      # avoid "warning: conflicting chdir during another chdir block"
      @current_dir = Pathname.pwd
      Dir.chdir(temp_dir)
      FileUtils.cp_r(spec_dir.join("script"), temp_dir)
    end

    after do
      Dir.chdir(@current_dir)
    end

    shared_examples :should_create_job_directories do
      let(:job_dir)    { temp_dir_path.join("jobs", job_name) }
      let(:copied_file){ job_dir.join("script", "build_success.sh") }

      it { expect(job_dir).to be_exist }
      it { expect(copied_file).to be_exist }
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

      describe "should create job directories" do
        before do
          # exercise
          subject
        end

        it_behaves_like :should_create_job_directories do
          let(:job_name){ "RUBY_1.9_DATABASE_mysql" }
        end

        it_behaves_like :should_create_job_directories do
          let(:job_name){ "RUBY_2.0_DATABASE_postgresql" }
        end
      end
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

      describe "should create job directories" do
        before do
          # exercise
          subject
        end

        it_behaves_like :should_create_job_directories do
          let(:job_name){ "RUBY_1.9_DATABASE_mysql" }
        end

        it_behaves_like :should_create_job_directories do
          let(:job_name){ "RUBY_2.0_DATABASE_postgresql" }
        end
      end
    end
  end

  describe "#copy_recursive" do
    subject{ Paraduct::ParallelRunner.copy_recursive(source_dir, destination_dir) }

    include_context "uses temp dir"

    let(:source_dir)     { temp_dir_path }
    let(:destination_dir){ temp_dir_path.join("jobs", "RUBY_1.9_DATABASE_mysql") }
    let(:copied_file)    { destination_dir.join("build_success.sh") }
    let(:not_copied_file){ destination_dir.join("jobs", "dummy.txt") }

    before do
      # setup
      FileUtils.cp_r(spec_dir.join("script", "jobs"), source_dir)
      FileUtils.cp_r(spec_dir.join("script", "build_success.sh"), source_dir)

      # exercise
      subject
    end

    it { expect(destination_dir).to be_exist }
    it { expect(copied_file).to be_exist }
    it { expect(not_copied_file).not_to be_exist }

    # after do
    #   puts `tree #{source_dir}`
    # end
  end
end
