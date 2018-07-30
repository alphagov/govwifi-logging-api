class PerformancePlatform::Gateway::UniqueUsers
  def initialize(period:)
    @period = period.to_s
  end

  def fetch_stats
    {
      count: result[:count].to_i,
      metric_name: 'unique-users',
      period: period
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end

  def result
    repository.unique_users_stats(period: period) || Hash.new(0)
  end

  attr_reader :period
end
