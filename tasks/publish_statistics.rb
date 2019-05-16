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

task :publish_weekly_statistics, [:date] do |_, args|
  args.with_defaults(date: Date.today.to_s)
  logger.info("Publishing weekly statistics with #{args[:date]}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  active_users_gateway = PerformancePlatform::Gateway::ActiveUsers.new(period: 'week', date: args[:date])
  active_users_presenter = PerformancePlatform::Presenter::ActiveUsers.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: active_users_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: active_users_presenter)
end

task :publish_monthly_statistics, [:date] do |_, args|
  args.with_defaults(date: Date.today.to_s)
  logger.info("Publishing monthly statistics with #{args[:date]}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  active_users_gateway = PerformancePlatform::Gateway::ActiveUsers.new(period: 'month', date: args[:date])
  active_users_presenter = PerformancePlatform::Presenter::ActiveUsers.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: active_users_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: active_users_presenter)
end
