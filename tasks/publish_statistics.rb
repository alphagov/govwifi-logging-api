require 'logger'
logger = Logger.new(STDOUT)

task :synchronize_ip_locations do
  source_gateway = PerformancePlatform::Gateway::S3IpLocations.new
  destination_gateway = PerformancePlatform::Gateway::SequelIPLocations.new
  PerformancePlatform::UseCase::SynchronizeIpLocations.new(
    source_gateway: source_gateway,
    destination_gateway: destination_gateway
  ).execute
end

task :publish_daily_statistics, [:date] => [:synchronize_ip_locations] do |_, args|
  args.with_defaults(date: Date.today.to_s)
  logger.info("Publishing daily statistics with #{args}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  account_usage_gateway = PerformancePlatform::Gateway::AccountUsage.new(period: 'day', date: args[:date])
  account_usage_presenter = PerformancePlatform::Presenter::AccountUsage.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: account_usage_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: account_usage_presenter)
end

task :publish_weekly_statistics, [:date] do |_, args|
  logger.info("Publishing weekly statistics with #{args}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  unique_users_gateway = PerformancePlatform::Gateway::UniqueUsers.new(period: 'week', date: args[:date])
  unique_users_presenter = PerformancePlatform::Presenter::UniqueUsers.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: unique_users_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: unique_users_presenter)
end

task :publish_monthly_statistics, [:date] do |_, args|
  logger.info("Publishing monthly statistics with #{args}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  unique_users_gateway = PerformancePlatform::Gateway::UniqueUsers.new(period: 'month', date: args[:date])
  unique_users_presenter = PerformancePlatform::Presenter::UniqueUsers.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: unique_users_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: unique_users_presenter)
end
