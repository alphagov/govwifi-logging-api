module Metrics
  class RoamingUsers
    VALID_PERIODS = %w[week day month].freeze

    def initialize(period:,
                   date: Date.today.to_s)
      raise ArgumentError unless VALID_PERIODS.include? period

      @period = period.to_s
      @date = Date.parse(date)
    end

    def to_s3
      S3Publisher.publish key, stats
    end

    def to_elasticsearch
      Performance::Gateway::Elasticsearch.new('roaming_users').write(stats)
    end

    def key
      "roaming-users/roaming-users-#{@period}-#{@date}"
    end

  private

    def stats
      gateway = PerformancePlatform::Gateway::RoamingUsers.new(
        period: @period,
        date: @date.to_s,
      )

      gateway.fetch_stats
    end
  end
end
