PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics_to_elasticsearch".to_sym

  task name, [:date] do |_, args|
    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for Elasticsearch with #{args[:date]}")

    metrics_list = [Metrics::ActiveUsers.new(period: period, date: args[:date]),
                    Metrics::RoamingUsers.new(period: period, date: args[:date]),
                    Metrics::Volumetrics.new(period: period, date: args[:date]),
                    Metrics::CompletionRate.new(period: period, date: args[:date])]

    metrics_list.each do |metrics|
      logger.info("[#{metrics.key}] Fetching and uploading metrics...")

      metrics.to_elasticsearch

      logger.info("[#{metrics.key}] Done.")
    end
  end
end
