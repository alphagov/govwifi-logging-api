describe PerformancePlatform::UseCase::SendPerformanceReport do
  let(:performance_gateway) { PerformancePlatform::Gateway::PerformanceReport.new }
  let(:endpoint) { "https://performance-platform/" }
  let(:response) { { status: "ok" } }

  before do
    allow(presenter).to receive(:generate_timestamp).and_return("2018-07-16T00:00:00+00:00")

    expect(stats_gateway).to receive(:fetch_stats)
      .and_return(stats_gateway_response)

    ENV["PERFORMANCE_BEARER_ACTIVE_USERS"] = "googoogoo"
    ENV["PERFORMANCE_BEARER_UNIQUE_USERS"] = "boobooboo"
    ENV["PERFORMANCE_URL"] = endpoint
    ENV["PERFORMANCE_DATASET"] = dataset

    stub_request(:post, "#{endpoint}data/#{dataset}/#{metric}")
      .with(
        body: data[:payload].to_json,
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{bearer_token}",
        },
      )
      .to_return(
        body: response.to_json,
        status: 200,
      )
  end

  subject do
    described_class.new(
      stats_gateway: stats_gateway,
      performance_gateway: performance_gateway,
      logger: double(info: ""),
    )
  end

  context "report for active users" do
    let(:metric) { "active-users" }
    let(:dataset) { "gov-wifi" }
    let(:bearer_token) { "googoogoo" }
    let(:presenter) { PerformancePlatform::Presenter::ActiveUsers.new }
    let(:stats_gateway) { PerformancePlatform::Gateway::ActiveUsers.new(period: "week") }
    let(:stats_gateway_response) do
      {
        users: 3,
        metric_name: "active-users",
        period: "week",
      }
    end

    let(:data) do
      {
        metric_name: "active-users",
        payload: [
          {
            _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2FjdGl2ZS11c2Vyc3VzZXJz",
            _timestamp: "2018-07-16T00:00:00+00:00",
            dataType: "active-users",
            period: "week",
            type: "users",
            count: 3,
          },
        ],
      }
    end

    it "fetches stats and sends them to Performance service" do
      expect(subject.execute(presenter: presenter)["status"]).to eq("ok")
    end
  end

  context "report for unique users" do
    let(:metric) { "unique-users" }
    let(:dataset) { "gov-wifi" }
    let(:bearer_token) { "boobooboo" }
    let(:presenter) { PerformancePlatform::Presenter::UniqueUsers.new }

    context "weekly" do
      let(:stats_gateway) { PerformancePlatform::Gateway::UniqueUsers.new(period: "week") }
      let(:stats_gateway_response) do
        {
          metric_name: "unique-users",
          period: "week",
          count: 5,
        }
      end

      let(:data) do
        {
          metric_name: "umnique-users",
          payload: [
            {
              _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla3VuaXF1ZS11c2Vycw==",
              _timestamp: "2018-07-16T00:00:00+00:00",
              dataType: "unique-users",
              period: "week",
              count: 5,
            },
          ],
        }
      end

      it "fetches stats and sends them to Performance service" do
        expect(subject.execute(presenter: presenter)["status"]).to eq("ok")
      end
    end

    context "monthly" do
      let(:stats_gateway) { PerformancePlatform::Gateway::UniqueUsers.new(period: "month") }
      let(:stats_gateway_response) do
        {
          metric_name: "unique-users",
          period: "month",
          count: 12_345,
        }
      end

      let(:data) do
        {
          metric_name: "umnique-users",
          payload: [
            {
              _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpbW9udGh1bmlxdWUtdXNlcnM=",
              _timestamp: "2018-07-16T00:00:00+00:00",
              dataType: "unique-users",
              period: "month",
              month_count: 12_345,
            },
          ],
        }
      end

      it "fetches stats and sends them to Performance service" do
        expect(subject.execute(presenter: presenter)["status"]).to eq("ok")
      end
    end
  end
end
