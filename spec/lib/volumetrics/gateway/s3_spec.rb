require_relative "../../metrics/s3_fake_client"

describe Volumetrics::Gateway::S3 do
  let(:s3_client) { Metrics.fake_s3_client }

  before do
    ENV["S3_METRICS_BUCKET"] = "stub-bucket"
    allow(Services).to receive(:s3_client).and_return s3_client

    100.times do |t|
      s3_client.put_object({ bucket: "stub-bucket", key: "foo/bar-#{t}", body: { foo: "bar-#{t}" }.to_json })
    end

    1500.times do |t|
      s3_client.put_object({ bucket: "stub-bucket", key: "volumetrics/foo-#{t}", body: { bar: "baz-#{t}" }.to_json })
    end
  end

  it "has expected number of objects" do
    expect(subject.count).to eq(1500)
  end

  it "has expected first object" do
    expect(subject.to_a.first).to eq({ key: "foo-0", body: { "bar" => "baz-0" } })
  end

  it "has expected last object" do
    expect(subject.to_a.last).to eq({ key: "foo-1499", body: { "bar" => "baz-1499" } })
  end
end
