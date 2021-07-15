module Performance
  module Metrics
    ELASTICSEARCH_INDEX = "govwifi-metrics".freeze

    PERIODS = {
      daily: "day",
      weekly: "week",
      monthly: "month",
    }.freeze
  end
end
