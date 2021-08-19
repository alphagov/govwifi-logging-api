describe Performance::Metrics::RequestStatsSender do
  let(:elasticsearch_client) { spy }
  let(:sessions) { DB[:sessions] }
  let(:ip1) { "12.12.12.12" }
  let(:ip2) { "20.20.20.20" }
  let(:ip3) { "20.30.40.50" }
  let(:time_string) { "2021-08-18 15:18:08" }
  let(:time) { Time.parse(time_string) }

  before :each do
    allow(Services).to receive(:elasticsearch_client).and_return elasticsearch_client
    sessions.truncate
  end
  it "Sends nothing" do
    Performance::Metrics::RequestStatsSender.new(date_time: time).send_data
    expect(elasticsearch_client).to_not have_received(:bulk)
  end
  it "Sends the number of successful and failed requests in the last hour to elasticsearch" do
    sessions.insert(
      siteIP: ip1,
      start: time,
      success: "1",
    )
    sessions.insert(
      siteIP: ip1,
      start: time - 60,
      success: "1",
    )
    sessions.insert(
      siteIP: ip1,
      start: time - 60,
      success: "0",
    )
    sessions.insert(
      siteIP: ip2,
      start: time - 60,
      success: "1",
    )
    sessions.insert(
      siteIP: ip2,
      username: "elis",
      start: time - 60 * 60 * 2,
      success: "1",
    )

    Performance::Metrics::RequestStatsSender.new(date_time: time).send_data
    expect(elasticsearch_client).to have_received(:bulk).with(index: Performance::Metrics::RequestStatsSender::SESSION_INDEX,
                                                              body: match_array([{ time: time_string, Failures: 1, Successes: 2, siteIP: "12.12.12.12" },
                                                                                 { time: time_string, Failures: 0, Successes: 1, siteIP: "20.20.20.20" }]))
  end
end
