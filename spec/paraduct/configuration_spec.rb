describe Paraduct::Configuration do
  let(:config){ Paraduct.configuration }

  before do
    # use spec/.paraduct.yml
    allow_any_instance_of(Paraduct::Configuration).to receive(:root_dir){ spec_dir }
  end

  describe "#variables" do
    subject{ config.variables }

    it "should get variables in .paraduct.yml" do
      is_expected.to match(
        "ruby"     => ["1.9.3", "2.0.0", "2.1.2"],
        "database" => ["mysql", "postgresql"],
        "rails"    => ["3.2.0", "4.0.0", "4.1.0"],
      )
    end
  end

  describe "#work_dir" do
    subject{ config.work_dir }

    it { should eq spec_dir.join("tmp/paraduct_workspace") }
  end

end
