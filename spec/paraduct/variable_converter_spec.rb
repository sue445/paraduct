describe Paraduct::VariableConverter do
  describe "#product" do
    subject { Paraduct::VariableConverter.product(variables) }

    context "with single variable" do
      let(:variables) do
        {
          "ruby" => ["1.9", "2.0", "2.1"],
        }
      end

      it { should have(3).entries }
      it { should include("ruby" => "1.9") }
      it { should include("ruby" => "2.0") }
      it { should include("ruby" => "2.1") }
    end

    context "with double variables" do
      let(:variables) do
        {
          "ruby"     => ["1.9", "2.0", "2.1"],
          "database" => ["mysql", "postgresql"],
        }
      end

      it { should have(6).entries }
      it { should include("ruby" => "1.9", "database" => "mysql") }
      it { should include("ruby" => "2.0", "database" => "mysql") }
      it { should include("ruby" => "2.1", "database" => "mysql") }
      it { should include("ruby" => "1.9", "database" => "postgresql") }
      it { should include("ruby" => "2.0", "database" => "postgresql") }
      it { should include("ruby" => "2.1", "database" => "postgresql") }
    end

    context "with triple variables" do
      let(:variables) do
        {
          "ruby"     => ["1.9", "2.0", "2.1"],
          "database" => ["mysql", "postgresql"],
          "rails"    => ["3.2", "4.0"],
        }
      end

      it { should have(12).entries }
      it { should include("ruby" => "1.9", "database" => "mysql",      "rails" => "3.2") }
      it { should include("ruby" => "2.0", "database" => "mysql",      "rails" => "3.2") }
      it { should include("ruby" => "2.1", "database" => "mysql",      "rails" => "3.2") }
      it { should include("ruby" => "1.9", "database" => "postgresql", "rails" => "3.2") }
      it { should include("ruby" => "2.0", "database" => "postgresql", "rails" => "3.2") }
      it { should include("ruby" => "2.1", "database" => "postgresql", "rails" => "3.2") }
      it { should include("ruby" => "1.9", "database" => "mysql",      "rails" => "4.0") }
      it { should include("ruby" => "2.0", "database" => "mysql",      "rails" => "4.0") }
      it { should include("ruby" => "2.1", "database" => "mysql",      "rails" => "4.0") }
      it { should include("ruby" => "1.9", "database" => "postgresql", "rails" => "4.0") }
      it { should include("ruby" => "2.0", "database" => "postgresql", "rails" => "4.0") }
      it { should include("ruby" => "2.1", "database" => "postgresql", "rails" => "4.0") }
    end
  end

  describe "#reject" do
    subject { Paraduct::VariableConverter.reject(product_variables, exclude_variables) }

    let(:product_variables) do
      [
        { "ruby" => "1.9", "database" => "mysql", "rails" => "3.2" },
        { "ruby" => "2.0", "database" => "mysql", "rails" => "3.2" },
        { "ruby" => "2.1", "database" => "mysql", "rails" => "3.2" },
      ]
    end

    context "with perfect matching" do
      let(:exclude_variables) do
        [
          { "rails" => "3.2", "ruby" => "2.0", "database" => "mysql" },
        ]
      end

      it do
        should contain_exactly(
          { "ruby" => "1.9", "database" => "mysql", "rails" => "3.2" },
          { "ruby" => "2.1", "database" => "mysql", "rails" => "3.2" }
        )
      end
    end

    context "with partial matching" do
      let(:exclude_variables) do
        [
          { "ruby" => "1.9" },
        ]
      end

      it do
        should contain_exactly(
          { "ruby" => "2.0", "database" => "mysql", "rails" => "3.2" },
          { "ruby" => "2.1", "database" => "mysql", "rails" => "3.2" }
        )
      end
    end
  end

  describe "#partial_match?" do
    subject { Paraduct::VariableConverter.partial_match?(parent_hash, child_hash) }

    context "with parent_hash == child_hash" do
      let(:parent_hash) { { a: 1, b: 2, c: 3 } }
      let(:child_hash) { { a: 1, b: 2, c: 3 } }

      it { should be true }
    end

    context "with parent_hash > child_hash" do
      let(:parent_hash) { { a: 1, b: 2, c: 3 } }
      let(:child_hash) { { a: 1, c: 3 } }

      it { should be true }
    end

    context "with parent_hash > child_hash, but value is not same" do
      let(:parent_hash) { { a: 1, b: 2, c: 3 } }
      let(:child_hash) { { a: 1, c: 4 } }

      it { should be false }
    end

    context "with parent_hash < child_hash" do
      let(:parent_hash) { { a: 1, b: 2, c: 3 } }
      let(:child_hash) { { a: 1, c: 3, d: 4 } }

      it { should be false }
    end
  end
end
