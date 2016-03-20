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
        "RUBY"     => ["1.9.3", "2.0.0", "2.1.2"],
        "DATABASE" => ["mysql", "postgresql"],
        "RAILS"    => ["3.2.0", "4.0.0", "4.1.0"],
      )
    end
  end
end
