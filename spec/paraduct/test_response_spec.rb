describe Paraduct::TestResponse do
  let(:test_response) { Paraduct::TestResponse.new }

  describe "#successful?" do
    subject { test_response.successful? }

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

  describe "#detail_message" do
    subject { test_response.detail_message }

    context "when successful" do
      before do
        test_response.jobs_push(successful: true, params: { "ruby" => "1.8", "database" => "sqlite3" }, formatted_params: "ruby=1.8, database=sqlite3")
        test_response.jobs_push(successful: true, params: { "ruby" => "1.9", "database" => "mysql" }, formatted_params: "ruby=1.9, database=mysql")
        test_response.jobs_push(successful: true, params: { "ruby" => "2.0", "database" => "postgresql" }, formatted_params: "ruby=2.0, database=postgresql")
      end

      it do
        should eq <<-EOS
======================================================
Passed:

  1) ruby=1.8, database=sqlite3
  2) ruby=1.9, database=mysql
  3) ruby=2.0, database=postgresql

3 jobs, 0 failures, 3 passed
        EOS
      end
    end

    context "when failure" do
      before do
        test_response.jobs_push(successful: true, params: { "ruby" => "1.8", "database" => "sqlite3" }, formatted_params: "ruby=1.8, database=sqlite3")
        test_response.jobs_push(successful: false, params: { "ruby" => "1.9", "database" => "mysql" }, formatted_params: "ruby=1.9, database=mysql")
        test_response.jobs_push(successful: false, params: { "ruby" => "2.0", "database" => "postgresql" }, formatted_params: "ruby=2.0, database=postgresql")
      end

      it do
        should eq <<-EOS
======================================================
Passed:

  1) ruby=1.8, database=sqlite3

Failures:

  1) ruby=1.9, database=mysql
  2) ruby=2.0, database=postgresql

3 jobs, 2 failures, 1 passed
        EOS
      end
    end
  end
end
