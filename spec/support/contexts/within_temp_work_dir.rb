shared_context :within_temp_work_dir do
  include_context "uses temp dir"

  before do
    # avoid "warning: conflicting chdir during another chdir block"
    @current_dir = Pathname.pwd
    Dir.chdir(temp_dir)
    FileUtils.cp_r(spec_dir.join("script"), temp_dir)
    FileUtils.cp(spec_dir.join(".paraduct.yml"), temp_dir)
    FileUtils.cp(spec_dir.join(".paraduct_rsync_exclude.txt"), temp_dir)
  end

  after do
    Dir.chdir(@current_dir)
  end
end
