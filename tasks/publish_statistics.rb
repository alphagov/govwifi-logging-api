require "logger"
require "./lib/performance/metrics"
logger = Logger.new($stdout)

task synchronize_ip_locations: :load_env do
  Performance::Metrics::IPSynchronizer.new.execute
end

Performance::Metrics::PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics".to_sym
  dependent_tasks = adverbial == :daily ? %i[load_env synchronize_ip_locations] : [:load_env]

  task name, [:date] => dependent_tasks do |_, args|
    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for S3 with #{args[:date]}")

    metrics_list = %i[active_users completion_rate roaming_users volumetrics]
    metrics_list.each do |metrics|
      metric_sender = Performance::Metrics::MetricSender.new(period:, date: args[:date], metric: metrics)
      logger.info("[#{metric_sender.key}] Fetching and uploading metrics...")

      metric_sender.to_s3
      metric_sender.to_elasticsearch

      logger.info("[#{metric_sender.key}] Done.")
    end
  end
end
