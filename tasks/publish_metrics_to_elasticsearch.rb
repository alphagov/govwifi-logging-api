require "logger"
require "./lib/performance/metrics"
logger = Logger.new($stdout)

Performance::Metrics::PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics_to_elasticsearch".to_sym

  task name, [:date] => :load_env do |_, args|
    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for Elasticsearch with #{args[:date]}")

    metrics_list = %i[active_users completion_rate roaming_users volumetrics]
    metrics_list.each do |metrics|
      metric_sender = Performance::Metrics::MetricSender.new(period: period, date: args[:date], metric: metrics)

      logger.info("[#{metric_sender.key}] Fetching and uploading metrics...")

      metric_sender.to_elasticsearch

      logger.info("[#{metric_sender.key}] Done.")
    end
  end
end
