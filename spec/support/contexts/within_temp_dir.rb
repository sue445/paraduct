shared_context :within_temp_dir do
  include_context "uses temp dir"

  before do
    # avoid "warning: conflicting chdir during another chdir block"
    @current_dir = Pathname.pwd
    Dir.chdir(temp_dir)
  end

  after do
    Dir.chdir(@current_dir)
  end
end
