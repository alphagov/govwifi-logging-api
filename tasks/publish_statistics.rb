task :publish_daily_statistics do
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  account_usage_gateway = PerformancePlatform::Gateway::AccountUsage.new
  account_usage_presenter = PerformancePlatform::Presenter::AccountUsage.new

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: account_usage_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: account_usage_presenter)
end
