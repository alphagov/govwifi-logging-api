class Performance::UseCase::RoamingUsers
  def initialize(period:, date: Date.today.to_s)
    @period = period.to_s
    @date = Date.parse(date)
  end

  def fetch_stats
    {
      active: active_users_count,
      roaming: roaming_users_count,
      metric_name: "roaming-users",
      period: period,
      date: date.to_s,
    }
  end

private

  def repository
    Performance::Repository::Session
  end

  def active_users_count
    repository.active_users_stats(period: period, date: date)
  end

  def roaming_users_count
    repository.roaming_users_count(period: period, date: date)
  end

  attr_reader :period, :date
end
