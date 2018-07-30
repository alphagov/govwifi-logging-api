describe PerformancePlatform::UseCase::SendPerformanceReport do
  let(:performance_gateway) { PerformancePlatform::Gateway::PerformanceReport.new }
  let(:endpoint) { 'https://performance-platform/' }
  let(:response) { { status: 'ok' } }

  before do
    allow(presenter).to receive(:generate_timestamp).and_return('2018-07-16T00:00:00+00:00')

    expect(stats_gateway).to receive(:fetch_stats)
      .and_return(stats_gateway_response)

    ENV['PERFORMANCE_BEARER_ACCOUNT_USAGE'] = 'googoogoo'
    ENV['PERFORMANCE_URL'] = endpoint
    ENV['PERFORMANCE_DATASET'] = dataset

    stub_request(:post, "#{endpoint}data/#{dataset}/#{metric}")
      .with(
    body: data[:payload].to_json,
    headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{bearer_token}"
    }
    )
      .to_return(
    body: response.to_json,
    status: 200
    )
  end

  subject do
    described_class.new(
      stats_gateway: stats_gateway,
      performance_gateway: performance_gateway
    )
  end

  context 'report for account usage' do
    let(:metric) { 'account-usage' }
    let(:dataset) { 'gov-wifi' }
    let(:bearer_token) { 'googoogoo' }
    let(:presenter) { PerformancePlatform::Presenter::AccountUsage.new }
    let(:stats_gateway) { PerformancePlatform::Gateway::AccountUsage.new }
    let(:stats_gateway_response) {
      {
        total: 2,
        transactions: 3,
        roaming: 1,
        one_time: 1,
        metric_name: 'account-usage',
        period: 'day'
      }
    }

    let(:data) {
      {
        metric_name: 'account-usage',
        payload: [
          {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZXRvdGFs',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'day',
            type: 'total',
            count: 2
          }, {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZXRyYW5zYWN0aW9ucw==',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'day',
            type: 'transactions',
            count: 3
          }, {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZXJvYW1pbmc=',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'day',
            type: 'roaming',
            count: 1
          }, {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZW9uZS10aW1l',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'day',
            type: 'one-time',
            count: 1
          }
        ]
      }
    }

    it 'fetches stats and sends them to Performance service' do
      expect(subject.execute(presenter: presenter)['status']).to eq('ok')
    end
  end

  # context 'report for unique users' do
  #   let(:metric) { 'unique-users' }
  #   let(:dataset) { 'gov-wifi' }
  #   let(:bearer_token) { 'googoogoo' }
  #   let(:presenter) { PerformancePlatform::Presenter::UniqueUsers.new }
  #   let(:stats_gateway) { PerformancePlatform::Gateway::UniqueUsers.new }
  #   let(:stats_gateway_response) {
  #     {
  #       total: 2,
  #       transactions: 3,
  #       roaming: 1,
  #       one_time: 1,
  #       metric_name: 'account-usage',
  #       period: 'day'
  #     }
  #   }

  #   let(:data) {
  #     {
  #       metric_name: 'account-usage',
  #       payload: [
  #         {
  #           _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZXRvdGFs',
  #           _timestamp: '2018-07-16T00:00:00+00:00',
  #           dataType: 'account-usage',
  #           period: 'day',
  #           type: 'total',
  #           count: 2
  #         }, {
  #           _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZXRyYW5zYWN0aW9ucw==',
  #           _timestamp: '2018-07-16T00:00:00+00:00',
  #           dataType: 'account-usage',
  #           period: 'day',
  #           type: 'transactions',
  #           count: 3
  #         }, {
  #           _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZXJvYW1pbmc=',
  #           _timestamp: '2018-07-16T00:00:00+00:00',
  #           dataType: 'account-usage',
  #           period: 'day',
  #           type: 'roaming',
  #           count: 1
  #         }, {
  #           _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5YWNjb3VudC11c2FnZW9uZS10aW1l',
  #           _timestamp: '2018-07-16T00:00:00+00:00',
  #           dataType: 'account-usage',
  #           period: 'day',
  #           type: 'one-time',
  #           count: 1
  #         }
  #       ]
  #     }
  #   }

  #   it 'fetches stats and sends them to Performance service' do
  #     expect(subject.execute(presenter: presenter)['status']).to eq('ok')
  #   end
  # end
end
