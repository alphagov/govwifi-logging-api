require "logger"
require "./lib/performance/metrics"

task :send_request_statistics do
  Performance::Metrics::RequestStatsSender.new.send_data
end
