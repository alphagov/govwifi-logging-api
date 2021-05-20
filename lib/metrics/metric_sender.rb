# frozen_string_literal: true

module Metrics
  # Utility class to generate and publish a set of metrics for the
  # provided period and date arguments. It delegates the actual
  # generation to PerformancePlatform::Gateway::ActiveUsers and will
  # upload the result in the S3 bucket designated through
  # ENV['S3_METRICS_BUCKET'].
  class MetricSender
    VALID_PERIODS = %w[week day month].freeze
    VALID_STATS = %w[active_users completion_rate roaming_users volumetrics].freeze
    STATS = {
      active_users: PerformancePlatform::Gateway::ActiveUsers,
      completion_rate: PerformancePlatform::Gateway::CompletionRate,
      roaming_users: PerformancePlatform::Gateway::RoamingUsers,
      volumetrics: PerformancePlatform::Gateway::Volumetrics,
    }.freeze

    def initialize(period:, date:, metric:)
      raise ArgumentError unless VALID_PERIODS.include? period
      raise ArgumentError unless STATS.keys.include? metric

      @metric = metric
      @period = period
      @date = date.to_s
    end

    def to_s3
      S3Publisher.publish "#{@metric}/#{key}", stats
    end

    def to_elasticsearch
      Performance::Gateway::Elasticsearch.new(@metric.to_s).write(key, stats)
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
