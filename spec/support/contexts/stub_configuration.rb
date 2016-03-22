shared_context :stub_configuration do
  before do
    allow_any_instance_of(Paraduct::Configuration).to receive(:config_data) { config_data.stringify_keys.with_indifferent_access }
  end

  let(:config_data) do
    {
      script: 'echo "NAME1=${NAME1}, NAME2=${NAME2}"',
      work_dir: "tmp/paraduct_workspace",
      variables: {
        "NAME1" => ["value1a", "value1b"],
        "NAME2" => ["value2a", "value2b"],
      },
    }
  end
end
