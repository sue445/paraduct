shared_context :within_temp_dir do
  include_context "uses temp dir"

  around do |example|
    Dir.chdir(temp_dir) do
      example.run
    end
  end
end
