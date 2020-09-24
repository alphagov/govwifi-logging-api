class PerformancePlatform::Presenter::RoamingUsers
  def initialize(date: Date.today.to_s)
    @date = Date.parse(date)
  end

  def present(stats:)
    @stats = stats
    @timestamp = generate_timestamp

    {
      metric_name: stats[:metric_name],
      payload: [
        as_hash(stats[:active], "active"),
        as_hash(stats[:roaming], "roaming"),
      ],
    }
  end

private

  def as_hash(count, type)
    {
      _id: encode_id(type),
      _timestamp: timestamp,
      dataType: stats[:metric_name],
      period: stats[:period],
      type: type,
      count: count,
    }
  end

  def generate_timestamp
    "#{date - 1}T00:00:00+00:00"
  end

  def encode_id(type)
    Common::Base64.encode_array(
      [
        timestamp,
        ENV.fetch("PERFORMANCE_DATASET"),
        stats[:period],
        stats[:metric_name],
        type,
      ],
    )
  end

  attr_reader :stats, :timestamp, :date
end
