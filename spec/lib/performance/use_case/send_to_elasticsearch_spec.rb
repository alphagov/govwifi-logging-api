describe Performance::UseCase::SendToElasticsearch do
  before do
    USER_DB[:userdetails].truncate
  end

  let(:user_repository) { Class.new(Performance::Repository::SignUp) { unrestrict_primary_key } }
  let(:elasticsearch_client) { spy }

  context "given a signup" do
    before do
      user_repository.create(username: "full", created_at: Date.today - 1)
      allow(Services).to receive(:elasticsearch_client).and_return elasticsearch_client
    end
    it "gets a data point from the database and writes it to elasticsearch" do
      expected_hash = {
        period_before: 1,
        cumulative: 1,
        sms_period_before: 0,
        sms_cumulative: 0,
        metric_name: "volumetrics",
        period: "day",
        email_period_before: 0,
        email_cumulative: 0,
        sponsored_cumulative: 0,
        sponsored_period_before: 0,
      }
      Performance::UseCase::SendToElasticsearch.new.execute
      expect(elasticsearch_client).to have_received(:index).with({ index: "volumetrics",
                                                                   body: expected_hash })
    end
  end
end
