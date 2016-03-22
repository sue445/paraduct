describe Paraduct::ParallelRunner do
  describe "#perform_all" do
    subject { Paraduct::ParallelRunner.perform_all(script: script, product_variables: product_variables, after_script: after_script) }

    include_context :within_temp_work_dir

    # after do
    #   puts `tree #{temp_dir}`
    # end

    shared_examples :create_job_directories do
      let(:job_dir) { temp_dir_path.join("tmp/paraduct_workspace/#{job_name}") }
      let(:copied_file) { job_dir.join("script/build_success.sh") }

      it { expect(job_dir).to be_exist }
      it { expect(copied_file).to be_exist }
    end

    shared_examples :dont_create_job_directories do
      let(:job_dir) { temp_dir_path.join("tmp/paraduct_workspace/#{job_name}") }
      let(:copied_file) { job_dir.join("script/build_success.sh") }

      it { expect(job_dir).not_to be_exist }
      it { expect(copied_file).not_to be_exist }
    end

    describe "with script file test" do
      let(:script) { "./script/build_success.sh" }
      let(:after_script) { "./script/build_finish.sh" }
      let(:product_variables) do
        [
          { "RUBY" => "1.9", "DATABASE" => "mysql" },
          { "RUBY" => "2.0", "DATABASE" => "postgresql" },
        ]
      end

      its(:jobs) do
        should include(
          job_name:         "RUBY_1.9_DATABASE_mysql",
          params:           { "RUBY" => "1.9", "DATABASE" => "mysql" },
          formatted_params: "RUBY=1.9, DATABASE=mysql",
          successful:       true,
          stdout:           "RUBY=1.9\nDATABASE=mysql\nFinish: RUBY=1.9, DATABASE=mysql\n"
        )
      end

      its(:jobs) do
        should include(
          job_name:         "RUBY_2.0_DATABASE_postgresql",
          params:           { "RUBY" => "2.0", "DATABASE" => "postgresql" },
          formatted_params: "RUBY=2.0, DATABASE=postgresql",
          successful:       true,
          stdout:           "RUBY=2.0\nDATABASE=postgresql\nFinish: RUBY=2.0, DATABASE=postgresql\n"
        )
      end

      context "When work_dir is not empty" do
        before do
          allow(Paraduct.config).to receive(:work_dir) { "tmp/paraduct_workspace" }
        end

        describe "should create job directories" do
          before do
            # exercise
            subject
          end

          it_behaves_like :create_job_directories do
            let(:job_name) { "RUBY_1.9_DATABASE_mysql" }
          end

          it_behaves_like :create_job_directories do
            let(:job_name) { "RUBY_2.0_DATABASE_postgresql" }
          end
        end
      end

      context "When work_dir is empty" do
        before do
          allow(Paraduct.config).to receive(:work_dir) { nil }
        end

        describe "should not create job directories" do
          before do
            # exercise
            subject
          end

          it_behaves_like :dont_create_job_directories do
            let(:job_name) { "RUBY_1.9_DATABASE_mysql" }
          end

          it_behaves_like :dont_create_job_directories do
            let(:job_name) { "RUBY_2.0_DATABASE_postgresql" }
          end
        end
      end
    end

    describe "without script file test" do
      let(:script) { 'echo "RUBY=${RUBY} DATABASE=${DATABASE}"' }
      let(:after_script) { 'echo "Finish: RUBY=${RUBY}, DATABASE=${DATABASE}"' }
      let(:product_variables) do
        [
          { "RUBY" => "1.9", "DATABASE" => "mysql" },
          { "RUBY" => "2.0", "DATABASE" => "postgresql" },
        ]
      end

      its(:jobs) do
        should include(
          job_name:         "RUBY_1.9_DATABASE_mysql",
          params:           { "RUBY" => "1.9", "DATABASE" => "mysql" },
          formatted_params: "RUBY=1.9, DATABASE=mysql",
          successful:       true,
          stdout:           "RUBY=1.9 DATABASE=mysql\nFinish: RUBY=1.9, DATABASE=mysql\n"
        )
      end

      its(:jobs) do
        should include(
          job_name:         "RUBY_2.0_DATABASE_postgresql",
          params:           { "RUBY" => "2.0", "DATABASE" => "postgresql" },
          formatted_params: "RUBY=2.0, DATABASE=postgresql",
          successful:       true,
          stdout:           "RUBY=2.0 DATABASE=postgresql\nFinish: RUBY=2.0, DATABASE=postgresql\n"
        )
      end

      context "When work_dir is not empty" do
        before do
          allow(Paraduct.config).to receive(:work_dir) { "tmp/paraduct_workspace" }
        end

        describe "should create job directories" do
          before do
            # exercise
            subject
          end

          it_behaves_like :create_job_directories do
            let(:job_name) { "RUBY_1.9_DATABASE_mysql" }
          end

          it_behaves_like :create_job_directories do
            let(:job_name) { "RUBY_2.0_DATABASE_postgresql" }
          end
        end
      end

      context "When work_dir is empty" do
        before do
          allow(Paraduct.config).to receive(:work_dir) { nil }
        end

        describe "should not create job directories" do
          before do
            # exercise
            subject
          end

          it_behaves_like :dont_create_job_directories do
            let(:job_name) { "RUBY_1.9_DATABASE_mysql" }
          end

          it_behaves_like :dont_create_job_directories do
            let(:job_name) { "RUBY_2.0_DATABASE_postgresql" }
          end
        end
      end
    end
  end
end
