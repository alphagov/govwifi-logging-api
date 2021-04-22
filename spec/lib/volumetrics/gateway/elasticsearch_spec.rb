describe Volumetrics::Gateway::Elasticsearch do
  let(:elasticsearch_client) { double(index: nil) }
  let(:url) { "http://#{ENV['VOLUMETRICS_ENDPOINT']}:9200/volumetrics/object/bar" }

  before do
    ENV["VOLUMETRICS_ENDPOINT"] = "foo"

    stub_request(:put, url).with(
      body: { foo: "bar" }.to_json,
    ).to_return(status: 200)
  end

  it "calls ElasticSearch API with expected args" do
    subject.write("bar", { foo: "bar" })

    assert_requested :put, url,
                     body: { foo: "bar" }.to_json,
                     times: 1
  end
end
