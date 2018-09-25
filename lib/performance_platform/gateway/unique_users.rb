class PerformancePlatform::Gateway::UniqueUsers
  def initialize(period:, date: Date.today.to_s)
    @period = period.to_s
    @date = Date.parse(date)
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
    repository.unique_users_stats(period: period, date: date) || Hash.new(0)
  end

  attr_reader :period, :date
end
