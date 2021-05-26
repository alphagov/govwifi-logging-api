require "logger"
logger = Logger.new(STDOUT)

task :synchronize_ip_locations do
  Performance::Metrics::IPSynchronizer.new.execute
end

Performance::Metrics::MetricSender::PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics".to_sym
  dependent_tasks = adverbial == :daily ? [:synchronize_ip_locations] : []

  task name, [:date] => dependent_tasks do |_, args|
    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for S3 with #{args[:date]}")

    metrics_list = %i[active_users completion_rate roaming_users volumetrics]
    metrics_list.each do |metrics|
      metric_sender = Performance::Metrics::MetricSender.new(period: period, date: args[:date], metric: metrics)
      logger.info("[#{metric_sender.key}] Fetching and uploading metrics...")

      metric_sender.to_s3

      logger.info("[#{metric_sender.key}] Done.")
    end
  end
end
