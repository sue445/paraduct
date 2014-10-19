describe Paraduct::TestResponse do
  describe "#successful?" do
    subject{ test_response.successful? }

    let(:test_response){ Paraduct::TestResponse.new }

    context "not include failure" do
      before do
        test_response.jobs_push(successful: true)
        test_response.jobs_push(successful: true)
      end

      it { should be true }
    end

    context "include failure" do
      before do
        test_response.jobs_push(successful: true)
        test_response.jobs_push(successful: false)
      end

      it { should be false }
    end
  end
end
