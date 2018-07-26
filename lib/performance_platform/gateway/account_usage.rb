class PerformancePlatform::Gateway::AccountUsage
  def fetch_stats
    result = repository.stats || Hash.new(0)

    {
      total: result[:total].to_i,
      transactions: result[:per_site],
      roaming: result[:per_site] - result[:total],
      one_time: result[:total] - (result[:per_site] - result[:total]),
      metric_name: 'account-usage',
      period: 'day'
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end
end
