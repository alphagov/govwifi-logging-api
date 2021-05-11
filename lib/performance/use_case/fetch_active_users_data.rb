class Performance::UseCase::FetchActiveUsersData
  VALID_PERIODS = %w[week day month].freeze

  def initialize(period:, date: Date.today.to_s)
    raise ArgumentError unless VALID_PERIODS.include? attrs[:period]

    @period = period
    @date = date
  end

  def fetch
    result = repository.active_users_stats(period: @period, date: @date) || Hash.new(0)

    {
      users: result[:total],
      metric_name: "active-users",
      period: @period,
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end
end
