describe Performance::Gateway::Elasticsearch do
  let(:subject) { described_class.new("volumetrics") }
  let(:elasticsearch_client) { double(index: nil) }
  let(:url) { "http://#{ENV['VOLUMETRICS_ENDPOINT']}:9200/volumetrics/_doc/bar" }
  let(:elasticsearch_url) { "http://#{ENV['VOLUMETRICS_ENDPOINT']}:9200/" }

  before do
    ENV["VOLUMETRICS_ENDPOINT"] = "foo"

    stub_request(:put, url)
      .with(
        body: { foo: "bar" }.to_json,
      )
      .to_return(
        status: 200,
        body: "".dup,
      )

    stub_request(:get, elasticsearch_url)
    .to_return_json(
      status: 200,
      body: { version: { number: 7.9, distribution: "opensearch" } },
      headers: {},
    )
  end

  it "calls ElasticSearch API with expected args" do
    subject.write("bar", { foo: "bar" })

    assert_requested :put, url,
                     body: { foo: "bar" }.to_json,
                     times: 1
  end
end
