module Metrics
  class CompletionRate
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
      "completion_rate/completion_rate-#{@period}-#{@date}"
    end

  private

    def stats
      {
        period: @period,
        metric_name: "completion-rate",
        sms_registered: sms_registered.count,
        sms_logged_in: sms_logged_in.count,
        email_registered: email_registered.count,
        email_logged_in: email_logged_in.count,
        sponsor_registered: sponsor_registered.count,
        sponsor_logged_in: sponsor_logged_in.count,
      }
    end

    def repository
      Performance::Repository::SignUp
    end

    def sms_registered
      repository.self_sign.with_sms.send("#{@period}_before", @date)
    end

    def email_registered
      repository.self_sign.with_email.send("#{@period}_before", @date)
    end

    def sponsor_registered
      repository.sponsored.send("#{@period}_before", @date)
    end

    def sms_logged_in
      sms_registered.with_successful_login
    end

    def email_logged_in
      email_registered.with_successful_login
    end

    def sponsor_logged_in
      sponsor_registered.with_successful_login
    end
  end
end
