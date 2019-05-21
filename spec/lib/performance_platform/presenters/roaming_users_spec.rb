describe PerformancePlatform::Presenter::RoamingUsers do
  before do
    Timecop.freeze(Date.new(2018, 2, 1))
    ENV['PERFORMANCE_DATASET'] = 'some-dataset'
  end

  let(:gateway_results) do
    {
      metric_name: 'some-metric-name',
      roaming: 100,
      active: 200,
      period: 'week'
    }
  end

  it 'presents the correct data' do
    expected_result = {
      metric_name: 'some-metric-name',
      payload: [
        {
          _id: "MjAxOC0wMS0zMVQwMDowMDowMCswMDowMHNvbWUtZGF0YXNldHdlZWtzb21lLW1ldHJpYy1uYW1lYWN0aXZl",
          _timestamp: "2018-01-31T00:00:00+00:00",
          count: 200,
          dataType: "some-metric-name",
          period: "week",
          type: "active"
        }, {
          _id: "MjAxOC0wMS0zMVQwMDowMDowMCswMDowMHNvbWUtZGF0YXNldHdlZWtzb21lLW1ldHJpYy1uYW1lcm9hbWluZw==",
          _timestamp: "2018-01-31T00:00:00+00:00",
          count: 100,
          dataType: "some-metric-name",
          period: "week",
          type: "roaming"
        }
      ]
    }

    expect(subject.present(stats: gateway_results)).to eq(expected_result)
  end
end
