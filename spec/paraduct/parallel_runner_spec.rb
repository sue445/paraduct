describe Paraduct::ParallelRunner do
  describe "#perform_all" do
    subject{ Paraduct::ParallelRunner.perform_all(script, product_variables) }

    include_context :within_temp_work_dir

    # after do
    #   puts `tree #{temp_dir}`
    # end

    shared_examples :create_job_directories do
      let(:job_dir)    { temp_dir_path.join("tmp/paraduct_workspace/#{job_name}") }
      let(:copied_file){ job_dir.join("script/build_success.sh") }

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

      it do
        should match_array [
          a_hash_including(
            job_name:   "RUBY_1.9_DATABASE_mysql",
            successful: true,
            stdout:     "RUBY=1.9\nDATABASE=mysql\n"
          ),
          a_hash_including(
            job_name:   "RUBY_2.0_DATABASE_postgresql",
            successful: true,
            stdout:     "RUBY=2.0\nDATABASE=postgresql\n"
          )
        ]
      end

      describe "should create job directories" do
        before do
          # exercise
          subject
        end

        it_behaves_like :create_job_directories do
          let(:job_name){ "RUBY_1.9_DATABASE_mysql" }
        end

        it_behaves_like :create_job_directories do
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

      it do
        should match_array [
          a_hash_including(
            job_name:   "RUBY_1.9_DATABASE_mysql",
            successful: true,
            stdout:     "RUBY=1.9 DATABASE=mysql\n"
          ),
          a_hash_including(
            job_name:   "RUBY_2.0_DATABASE_postgresql",
            successful: true,
            stdout:     "RUBY=2.0 DATABASE=postgresql\n"
          )
        ]
      end

      describe "should create job directories" do
        before do
          # exercise
          subject
        end

        it_behaves_like :create_job_directories do
          let(:job_name){ "RUBY_1.9_DATABASE_mysql" }
        end

        it_behaves_like :create_job_directories do
          let(:job_name){ "RUBY_2.0_DATABASE_postgresql" }
        end
      end
    end
  end
end
