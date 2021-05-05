describe Performance::Gateway::Elasticsearch do
  let(:subject) { described_class.new("volumetrics") }
  let(:elasticsearch_client) { double(index: nil) }
  let(:url) { "http://#{ENV['VOLUMETRICS_ENDPOINT']}:9200/volumetrics/_doc" }

  before do
    ENV["VOLUMETRICS_ENDPOINT"] = "foo"

    stub_request(:post, url).with(
      body: { foo: "bar" }.to_json,
    ).to_return(status: 200)
  end

  it "calls ElasticSearch API with expected args" do
    subject.write(foo: "bar")

    assert_requested :post, url,
                     body: { foo: "bar" }.to_json,
                     times: 1
  end
end
