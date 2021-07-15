# frozen_string_literal: true

module Performance::Metrics
  # Utility class to generate and publish a set of metrics for the
  # provided period and date arguments. It delegates the actual
  # generation to PerformancePlatform::Gateway::ActiveUsers and will
  # upload the result in the S3 bucket designated through
  # ENV['S3_METRICS_BUCKET'].
  class MetricSender
    STATS = {
      active_users: Performance::UseCase::ActiveUsers,
      completion_rate: Performance::UseCase::CompletionRate,
      roaming_users: Performance::UseCase::RoamingUsers,
      volumetrics: Performance::UseCase::Volumetrics,
    }.freeze

    def initialize(period:, date:, metric:)
      raise ArgumentError unless PERIODS.values.include? period
      raise ArgumentError unless STATS.keys.include? metric

      @metric = metric
      @period = period
      @date = date.to_s
    end

    def to_s3
      S3Publisher.publish "#{@metric}/#{key}", stats
    end

    def to_elasticsearch
      Performance::Gateway::Elasticsearch.new(ELASTICSEARCH_INDEX).write(key, stats)
    end

    def key
      "#{@metric}-#{@period}-#{@date}"
    end

  private

    def stats
      gateway = STATS[@metric].new(
        period: @period,
        date: @date,
      )
      gateway.fetch_stats
    end
  end
end
