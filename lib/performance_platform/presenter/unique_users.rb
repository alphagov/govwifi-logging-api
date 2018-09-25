class PerformancePlatform::Presenter::UniqueUsers
  def present(stats:, date: Date.today.to_s)
    @stats = stats
    @timestamp = generate_timestamp
    @date = date

    {
      metric_name: stats[:metric_name],
      payload: [
        {
          _id: encode_id,
          _timestamp: timestamp,
          dataType: stats[:metric_name],
          period: stats[:period],
          count_field_name => stats[:count]
        }
      ]
    }
  end

private

  def generate_timestamp
    "#{date - 1}T00:00:00+00:00"
  end

  def encode_id
    Common::Base64.encode_array(
      [
        timestamp,
        ENV.fetch('PERFORMANCE_DATASET'),
        stats[:period],
        stats[:metric_name]
      ]
    )
  end

  def count_field_name
    stats[:period] == 'month' ? 'month_count' : 'count'
  end

  attr_reader :stats, :timestamp, :date
end
