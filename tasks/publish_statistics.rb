require "logger"
logger = Logger.new(STDOUT)

task :synchronize_ip_locations do
  Metrics::IPSynchronizer.new.execute
end

PERIODS = {
  daily: "day",
  weekly: "week",
  monthly: "month",
}.freeze

PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics".to_sym
  dependent_tasks = adverbial == :daily ? [:synchronize_ip_locations] : []

  task name, [:date] => dependent_tasks do |_, args|
    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for S3 with #{args[:date]}")

    metrics_list = [Metrics::ActiveUsers.new(period: period, date: args[:date]),
                    Metrics::RoamingUsers.new(period: period, date: args[:date])]

    metrics_list.each do |metrics|
      logger.info("[#{metrics.key}] Fetching and uploading metrics...")

      metrics.execute

      logger.info("[#{metrics.key}] Done.")
    end
  end
end
