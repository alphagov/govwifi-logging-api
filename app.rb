# frozen_string_literal: true

require "sequel"
require "sensible_logging"
require "sinatra/base"
require "sinatra/json"
require "./lib/loader"

class App < Sinatra::Base
  use Raven::Rack if defined? Raven
  register Sinatra::SensibleLogging

#   sensible_logging(
#     logger: Logger.new($stdout)
#   )

  configure do
    enable :json
    set :log_level, Logger::DEBUG
  end

  configure :production, :staging do
    set :dump_errors, false
  end

  configure :production do
    set :log_level, Logger::INFO
  end

  get "/healthcheck" do
    "Healthy"
  end

  post "/logging/post-auth" do
    logger = Logger.new($stdout)
    request_body = request.body.read
    client_ip = request.ip() || 'n/a'

    Logging::PostAuth.new.execute(params: JSON.parse(request_body))

    status 204

    message = "method=#{request.request_method()} path=#{request.path_info()} client=#{client_ip} status=#{status}"
    logger.info(message + request_body)
  end
end
