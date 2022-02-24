describe Performance::UseCase::SyncS3ToElasticsearch do
  subject do
    described_class.new(
      s3_gateway:,
      elasticsearch_gateway:,
    )
  end

  let(:s3_gateway) { double }
  let(:elasticsearch_gateway) { double(write: nil) }

  before do
    allow(s3_gateway).to receive(:each).and_yield("baz-2020-01-01", { foo: "bar" }).and_return %w[baz]
  end

  context "Given s3 and elasticsearch gateways" do
    before(:each) do
      subject.execute
    end

    it "calls each on the s3 gateway" do
      expect(s3_gateway).to have_received(:each)
    end

    it "calls write on the elasticsearch gateway with expected args" do
      expect(elasticsearch_gateway).to have_received(:write).with("baz-2020-01-01", { foo: "bar" })
    end
  end
end
