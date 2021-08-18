# frozen_string_literal: true

module Performance::Metrics
  class RequestStatsSender
    SESSION_INDEX = "session"

    def initialize(date_time: Time.now)
      @date_time = date_time
    end

    def send_data
      Performance::Gateway::Elasticsearch.new(SESSION_INDEX).bulk_write(stats) unless stats.empty?
    end

  private

    def stats
      Performance::Repository::Session.request_stats(date_time: @date_time).to_a
    end
  end
end
