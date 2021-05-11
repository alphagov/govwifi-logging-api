# frozen_string_literal: true

module Metrics
  # Utility class to generate and publish a set of metrics for the
  # provided period and date arguments. It delegates the actual
  # generation to PerformancePlatform::Gateway::ActiveUsers and will
  # upload the result in the S3 bucket designated through
  # ENV['S3_METRICS_BUCKET'].
  class ActiveUsers
    VALID_PERIODS = %w[week day month].freeze

    def initialize(attrs)
      raise ArgumentError unless VALID_PERIODS.include? attrs[:period]

      @period = attrs[:period]
      @date = attrs[:date]
    end

    def to_s3
      S3Publisher.publish key, stats
    end

    def to_elasticsearch
      Performance::Gateway::Elasticsearch.new('active_users').write(stats)
    end

    def key
      "active-users/active-users-#{@period}-#{@date}"
    end

  private

    def stats
      gateway = PerformancePlatform::Gateway::ActiveUsers.new(
        period: @period,
        date: @date,
      )
      gateway.fetch_stats
    end
  end
end
