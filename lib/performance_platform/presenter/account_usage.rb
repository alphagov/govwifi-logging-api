class PerformancePlatform::Presenter::AccountUsage
  def present(stats:)
    @stats = stats
    @timestamp = generate_timestamp

    {
      metric_name: stats[:metric_name],
      payload: [
        as_hash(stats[:total], 'total'),
        as_hash(stats[:transactions], 'transactions'),
        as_hash(stats[:roaming], 'roaming'),
        as_hash(stats[:one_time], 'one-time'),
      ]
    }
  end

private

  def generate_timestamp
    "#{Date.today - 1}T00:00:00+00:00"
  end

  def as_hash(count, type)
    {
      _id: encode_id(type),
      _timestamp: timestamp,
      dataType: stats[:metric_name],
      period: stats[:period],
      type: type,
      count: count
    }
  end

  def encode_id(type)
    Common::Base64.encode_array(
      [
        timestamp,
        ENV.fetch('PERFORMANCE_DATASET'),
        stats[:period],
        stats[:metric_name],
        type
      ]
    )
  end

  attr_reader :stats, :timestamp
end
