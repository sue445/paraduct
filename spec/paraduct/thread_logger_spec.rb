describe Paraduct::ThreadLogger do
  describe "#next_color" do
    it "can call many times" do
      20.times do
        expect(Paraduct::ThreadLogger.next_color).to be_an_instance_of Symbol
      end
    end
  end
end
