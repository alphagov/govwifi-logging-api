require 'logger'
logger = Logger.new(STDOUT)

task :publish_daily_statistics do
  logger.info('Publishing daily statistics')
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  account_usage_gateway = PerformancePlatform::Gateway::AccountUsage.new
  account_usage_presenter = PerformancePlatform::Presenter::AccountUsage.new

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: account_usage_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: account_usage_presenter)
end

task :publish_weekly_statistics do
  logger.info('Publishing weekly statistics')
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  unique_users_gateway = PerformancePlatform::Gateway::UniqueUsers.new(period: 'week')
  unique_users_presenter = PerformancePlatform::Presenter::UniqueUsers.new

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: unique_users_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: unique_users_presenter)
end

task :publish_monthly_statistics do
  logger.info('Publishing monthly statistics')
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  unique_users_gateway = PerformancePlatform::Gateway::UniqueUsers.new(period: 'month')
  unique_users_presenter = PerformancePlatform::Presenter::UniqueUsers.new

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: unique_users_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: unique_users_presenter)
end
