# frozen_string_literal: true

require 'sequel'
require 'sensible_logging'
require 'sinatra/base'
require 'sinatra/json'
require './lib/loader'

class App < Sinatra::Base
  register Sinatra::SensibleLogging

  sensible_logging(
    logger: Logger.new(STDOUT)
  )

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

  get '/healthcheck' do
    'Healthy'
  end

  get '/logging/post-auth/user/?:username?/cert-name/?:cert_name?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result' do
    Logging::PostAuth.new.execute(params: params)

    status 204
  end

  post '/logging/post-auth' do
    Logging::PostAuth.new.execute(params: JSON.parse(request.body.read))

    status 204
  end

  get '/*' do
    logger.info("Unhandled logging request: #{request.path}")
    status 204
  end
end
