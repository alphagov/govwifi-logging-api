module Metrics
  class RoamingUsers
    VALID_PERIODS = %w[week day month].freeze

    def initialize(period:,
                   date: Date.today.to_s)
      raise ArgumentError unless VALID_PERIODS.include? period

      @period = period.to_s
      @date = Date.parse(date)
    end

    def execute
      S3Publisher.publish key, stats
    end

    def key
      "roaming-users/roaming-users-#{@period}-#{@date}"
    end

  private

    def stats
      gateway = Metrics::Gateway::RoamingUsers.new(
        period: @period,
        date: @date.to_s,
      )

      gateway.fetch_stats
    end
  end
end
