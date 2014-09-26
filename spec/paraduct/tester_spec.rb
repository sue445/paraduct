describe Paraduct::Tester do
  describe "#product" do
    subject { Paraduct::Tester.product(variables) }

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
      it { should include("ruby" => "1.9", "database" => "mysql"     , "rails" => "3.2") }
      it { should include("ruby" => "2.0", "database" => "mysql"     , "rails" => "3.2") }
      it { should include("ruby" => "2.1", "database" => "mysql"     , "rails" => "3.2") }
      it { should include("ruby" => "1.9", "database" => "postgresql", "rails" => "3.2") }
      it { should include("ruby" => "2.0", "database" => "postgresql", "rails" => "3.2") }
      it { should include("ruby" => "2.1", "database" => "postgresql", "rails" => "3.2") }
      it { should include("ruby" => "1.9", "database" => "mysql"     , "rails" => "4.0") }
      it { should include("ruby" => "2.0", "database" => "mysql"     , "rails" => "4.0") }
      it { should include("ruby" => "2.1", "database" => "mysql"     , "rails" => "4.0") }
      it { should include("ruby" => "1.9", "database" => "postgresql", "rails" => "4.0") }
      it { should include("ruby" => "2.0", "database" => "postgresql", "rails" => "4.0") }
      it { should include("ruby" => "2.1", "database" => "postgresql", "rails" => "4.0") }
    end

  end

end
