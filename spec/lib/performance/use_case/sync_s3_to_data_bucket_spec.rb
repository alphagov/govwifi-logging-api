require_relative "../metrics/s3_fake_client"
describe Performance::UseCase::SyncS3ToDataBucket do
  subject do
    described_class.new(
      s3_gateway: s3_gateway,
      dest_bucket: dest_bucket,
      dest_key: dest_key,
    )
  end

  let(:s3_gateway) { Performance::Gateway::S3.new("prefix", source_bucket) }
  let(:source_bucket) { "source-bucket" }
  let(:dest_bucket) { "dest-bucket" }
  let(:dest_key) { "dest-key" }
  let(:s3_client) { Performance::Metrics.fake_s3_client }
  let(:data) do
    [
      { "a" => 1, "b" => 2 },
      { "c" => 3, "d" => 4 },
    ]
  end

  before do
    s3_client.put_object({ bucket: source_bucket, key: "prefix/one", body: data[0].to_json })
    s3_client.put_object({ bucket: source_bucket, key: "prefix/two", body: data[1].to_json })
    allow(Services).to receive(:s3_client).and_return s3_client
    subject.execute
  end

  it "calls each on the s3 gateway" do
    response = s3_client.get_object(bucket: dest_bucket, key: dest_key)
    expect(JSON.parse(response.body.read)).to match_array(data)
  end
end
