# frozen_string_literal: true

module Metrics
  # Utility class to generate and publish a set of metrics for the
  # provided period and date arguments. It delegates the actual
  # generation to PerformancePlatform::Gateway::ActiveUsers and will
  # upload the result in the S3 bucket designated through
  # ENV['S3_METRICS_BUCKET'].
  class ActiveUsers
    VALID_PERIODS = %w[week day month].freeze

    attr_reader :period, :date, :report, :s3

    def initialize(attrs)
      raise ArgumentError unless VALID_PERIODS.include? attrs[:period]

      @period = attrs[:period]
      @date = attrs[:date]

      @s3 = Aws::S3::Client.new(region: 'eu-west-2')
    end

    def generate!
      gateway = PerformancePlatform::Gateway::ActiveUsers.new(
        period: period,
        date: date
      )

      @report = gateway.fetch_stats
    end

    def key
      "logging-api-active-users-#{period}-#{date}"
    end

    def publish!
      if @report.nil?
        raise 'Nothing to publish; call generate! before publishing.'
      end

      bucket = ENV.fetch('S3_METRICS_BUCKET')

      @s3.put_object(
        bucket: bucket,
        key: key,
        body: report.to_json.to_s
      )
    end
  end
end
