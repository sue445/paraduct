shared_context :within_spec_dir do
  around do |example|
    Dir.chdir(spec_dir) do
      example.run
    end
  end
end
