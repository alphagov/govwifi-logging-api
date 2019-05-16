class PerformancePlatform::Gateway::ActiveUsers
  def initialize(period:, date: Date.today.to_s)
    @period = period
    @date = Date.parse(date)
  end

  def fetch_stats
    result = repository.active_users_stats(period: period, date: date) || Hash.new(0)

    {
      total: result[:total].to_i,
      transactions: result[:total],
      metric_name: 'active-users',
      period: period
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end

  attr_reader :period, :date
end
