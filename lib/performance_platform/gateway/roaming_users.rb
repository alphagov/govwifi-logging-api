class PerformancePlatform::Gateway::RoamingUsers
  def initialize(period:, date: Date.today.to_s)
    @period = period.to_s
    @date = Date.parse(date)
  end

  def fetch_stats
    {
      percentage: roaming_percentage.round,
      metric_name: 'roaming-users',
      period: period
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end

  def active_users_results
    @active_users_results ||= repository.active_users_stats(period: period, date: date)
  end

  def roaming_users_results
    repository.roaming_users_count(period: period, date: date)
  end

  def roaming_percentage
    return 0 if active_users_results.fetch(:total) == 0

    roaming_users_results.fetch(:total_roaming).to_f / active_users_results.fetch(:total).to_f * 100
  end

  attr_reader :period, :date
end
