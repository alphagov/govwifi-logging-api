describe Volumetrics::UseCase::SyncS3ToElasticsearch do
  subject do
    described_class.new(
      s3_gateway: s3_gateway,
      elasticsearch_gateway: elasticsearch_gateway,
    )
  end

  let(:s3_gateway) {
    double(fetch: [
      { filename: "baz", data: {} },
    ])
  }

  let(:elasticsearch_gateway) { double(write: nil) }

  context "Given s3 and elasticsearch gateways" do
    before(:each) do
      subject.execute
    end

    it "calls fetch on the s3 gateway" do
      expect(s3_gateway).to have_received(:fetch)
    end

    it "calls write on the elasticsearch gateway with expected args" do
      expect(elasticsearch_gateway).to have_received(:write).with("baz", {})
    end
  end
end
