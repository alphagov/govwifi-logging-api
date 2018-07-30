class PerformancePlatform::Gateway::UniqueUsers
  def fetch_stats
    result = repository.unique_users_stats || Hash.new(0)

    {
      count: result[:count].to_i,
      metric_name: 'unique-users',
      period: 'week'
    }
  end

private

  def repository
    PerformancePlatform::Repository::Session
  end
end
