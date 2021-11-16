class Performance::UseCase::ActiveUsers
  def initialize(period:, date: Date.today.to_s)
    @period = period
    @date = Date.parse(date)
  end

  def fetch_stats
    result = repository.active_users_stats(period: period, date: date)

    {
      users: result,
      metric_name: "active-users",
      period: period,
      date: date.to_s,
    }
  end

private

  def repository
    Performance::Repository::Session
  end

  attr_reader :period, :date
end
