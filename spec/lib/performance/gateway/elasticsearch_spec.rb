describe Performance::Gateway::Elasticsearch do
  let(:subject) { described_class.new("volumetrics") }
  let(:elasticsearch_client) { double(index: nil) }
  let(:url) { "http://#{ENV['VOLUMETRICS_ENDPOINT']}:9200/volumetrics/_doc/bar" }
  let(:elasticsearch_url) { "http://#{ENV['VOLUMETRICS_ENDPOINT']}:9200/" }

  before do
    ENV["VOLUMETRICS_ENDPOINT"] = "foo"

    stub_request(:put, url).with(
      body: { foo: "bar" }.to_json,
    ).to_return(status: 200)

    stub_request(:get, elasticsearch_url)
    .to_return(status: 200,
               body: {
                 tagline: "You Know, for Search",
                 version: { number: "7.9", build_flavor: "default" },
               }.to_json,
               headers: { "Content-Type" => "application/json" })
  end

  it "calls ElasticSearch API with expected args" do
    subject.write("bar", { foo: "bar" })

    assert_requested :put, url,
                     body: { foo: "bar" }.to_json,
                     times: 1
  end
end
