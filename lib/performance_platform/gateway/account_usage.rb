class PerformancePlatform::Gateway::AccountUsage
  def initialize(period:)
    @period = period
  end

  def fetch_stats
    result = repository.account_usage_stats(period: period) || Hash.new(0)

    {
      total: result[:total].to_i,
      transactions: result[:per_site],
      roaming: result[:per_site] - result[:total],
      one_time: result[:total] - (result[:per_site] - result[:total]),
      metric_name: 'account-usage',
      period: period
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end

  attr_reader :period
end
