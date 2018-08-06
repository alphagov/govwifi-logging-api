describe PerformancePlatform::UseCase::SendPerformanceReport do
  let(:performance_gateway) { PerformancePlatform::Gateway::PerformanceReport.new }
  let(:endpoint) { 'https://performance-platform/' }
  let(:response) { { status: 'ok' } }

  before do
    allow(presenter).to receive(:generate_timestamp).and_return('2018-07-16T00:00:00+00:00')

    expect(stats_gateway).to receive(:fetch_stats)
      .and_return(stats_gateway_response)

    ENV['PERFORMANCE_BEARER_ACCOUNT_USAGE'] = 'googoogoo'
    ENV['PERFORMANCE_BEARER_UNIQUE_USERS'] = 'boobooboo'
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
      performance_gateway: performance_gateway,
      logger: double(info: '')
    )
  end

  context 'report for account usage' do
    let(:metric) { 'account-usage' }
    let(:dataset) { 'gov-wifi' }
    let(:bearer_token) { 'googoogoo' }
    let(:presenter) { PerformancePlatform::Presenter::AccountUsage.new }
    let(:stats_gateway) { PerformancePlatform::Gateway::AccountUsage.new(period: 'week') }
    let(:stats_gateway_response) {
      {
        total: 2,
        transactions: 3,
        roaming: 1,
        one_time: 1,
        metric_name: 'account-usage',
        period: 'week'
      }
    }

    let(:data) {
      {
        metric_name: 'account-usage',
        payload: [
          {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2FjY291bnQtdXNhZ2V0b3RhbA==',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'week',
            type: 'total',
            count: 2
          },
          {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2FjY291bnQtdXNhZ2V0cmFuc2FjdGlvbnM=',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'week',
            type: 'transactions',
            count: 3
          },
          {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2FjY291bnQtdXNhZ2Vyb2FtaW5n',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'week',
            type: 'roaming',
            count: 1
          },
          {
            _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2FjY291bnQtdXNhZ2VvbmUtdGltZQ==',
            _timestamp: '2018-07-16T00:00:00+00:00',
            dataType: 'account-usage',
            period: 'week',
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

  context 'report for unique users' do
    let(:metric) { 'unique-users' }
    let(:dataset) { 'gov-wifi' }
    let(:bearer_token) { 'boobooboo' }
    let(:presenter) { PerformancePlatform::Presenter::UniqueUsers.new }

    context 'weekly' do
      let(:stats_gateway) { PerformancePlatform::Gateway::UniqueUsers.new(period: 'week') }
      let(:stats_gateway_response) {
        {
          metric_name: 'unique-users',
          period: 'week',
          count: 5
        }
      }

      let(:data) {
        {
          metric_name: 'umnique-users',
          payload: [
            {
              _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla3VuaXF1ZS11c2Vycw==',
              _timestamp: '2018-07-16T00:00:00+00:00',
              dataType: 'unique-users',
              period: 'week',
              count: 5
            }
          ]
        }
      }

      it 'fetches stats and sends them to Performance service' do
        expect(subject.execute(presenter: presenter)['status']).to eq('ok')
      end
    end

    context 'monthly' do
      let(:stats_gateway) { PerformancePlatform::Gateway::UniqueUsers.new(period: 'month') }
      let(:stats_gateway_response) {
        {
          metric_name: 'unique-users',
          period: 'month',
          count: 12345
        }
      }

      let(:data) {
        {
          metric_name: 'umnique-users',
          payload: [
            {
              _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpbW9udGh1bmlxdWUtdXNlcnM=',
              _timestamp: '2018-07-16T00:00:00+00:00',
              dataType: 'unique-users',
              period: 'month',
              month_count: 12345
            }
          ]
        }
      }

      it 'fetches stats and sends them to Performance service' do
        expect(subject.execute(presenter: presenter)['status']).to eq('ok')
      end
    end
  end
end
