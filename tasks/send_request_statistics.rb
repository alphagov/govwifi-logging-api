require "logger"

task send_request_statistics: :load_env do
  Performance::Metrics::RequestStatsSender.new.send_data
end
