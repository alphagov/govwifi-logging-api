class PerformancePlatform::Gateway::RoamingUsers
  def initialize(period:, date: Date.today.to_s)
    @period = period.to_s
    @date = Date.parse(date)
  end

  def fetch_stats
    {
      active: active_users_count,
      roaming: roaming_users_count,
      metric_name: 'roaming-users',
      period: period
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end

  def active_users_count
    repository.active_users_stats(period: period, date: date).fetch(:total)
  end

  def roaming_users_count
    repository.roaming_users_count(period: period, date: date).fetch(:total_roaming)
  end

  attr_reader :period, :date
end
