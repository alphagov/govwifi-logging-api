# frozen_string_literal: true

require 'sequel'
require 'sensible_logging'
require 'sinatra/base'
require 'sinatra/json'
require './lib/loader'

class App < Sinatra::Base
  register Sinatra::SensibleLogging

  sensible_logging(
    logger: Logger.new(STDOUT),
    log_tags: [->(request) { [request.body.read] }]
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

  post '/logging/post-auth' do
    Logging::PostAuth.new.execute(params: JSON.parse(request.body.read))

    status 204
  end
end
