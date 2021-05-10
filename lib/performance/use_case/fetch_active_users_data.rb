# frozen_string_literal: true

module Metrics
  # Utility class to generate and publish a set of metrics for the
  # provided period and date arguments. It delegates the actual
  # generation to PerformancePlatform::Gateway::ActiveUsers and will
  # upload the result in the S3 bucket designated through
  # ENV['S3_METRICS_BUCKET'].
  class FetchActiveUsersData
    VALID_PERIODS = %w[week day month].freeze

    def initialize(attrs)
      raise ArgumentError unless VALID_PERIODS.include? attrs[:period]

      @period = attrs[:period]
      @date = attrs[:date]
    end

    def execute
      S3Publisher.publish key, stats
    end

    def key
      "active-users/active-users-#{@period}-#{@date}"
    end

  private

    def stats
      result = repository.active_users_stats(period: @period, date: @date) || Hash.new(0)

      {
        users: result[:total],
        metric_name: "active-users",
        period: period,
      }
    end

    def repository
      PerformancePlatform::Repository::Session
    end
  end
end
