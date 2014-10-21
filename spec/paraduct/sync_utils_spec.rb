describe Paraduct::SyncUtils do
  describe "#copy_recursive" do
    subject{ Paraduct::SyncUtils.copy_recursive(source_dir, destination_dir) }

    include_context :within_temp_dir
    include_context :stub_configuration

    let(:config_data) do
      {
        rsync_option: {
          exclude_from: ".paraduct_rsync_exclude.txt",
        },
      }
    end

    let(:source_dir)     { temp_dir_path }
    let(:destination_dir){ temp_dir_path.join("tmp/paraduct_workspace/RUBY_1.9_DATABASE_mysql") }
    let(:copied_file)    { destination_dir.join("build_success.sh") }
    let(:not_copied_file){ destination_dir.join("tmp/paraduct_workspace/dummy.txt") }

    before do
      # setup
      FileUtils.cp_r(spec_dir.join("script/tmp/paraduct_workspace"), source_dir)
      FileUtils.cp(spec_dir.join("script/build_success.sh"), source_dir)
      FileUtils.cp(spec_dir.join(".paraduct_rsync_exclude.txt"), source_dir)

      # exercise
      subject
    end

    # after do
    #   puts `tree #{source_dir}`
    # end

    it { expect(destination_dir).to be_exist }
    it { expect(copied_file).to be_exist }
    it { expect(not_copied_file).not_to be_exist }
  end
end
