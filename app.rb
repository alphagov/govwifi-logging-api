# frozen_string_literal: true

require 'sequel'
require 'sinatra/base'
require 'sinatra/json'
require './lib/loader'

class App < Sinatra::Base
  configure do
    enable :logging
    enable :json

    set :logging, Logger::DEBUG
  end

  configure :production, :staging do
    set :dump_errors, false
  end

  configure :production do
    set :logging, Logger::INFO
  end

  get '/healthcheck' do
    'Healthy'
  end

  get '/logging/post-auth/user/?:username?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result' do
    post_auth_success = Logging::PostAuth.new.execute(params: params)

    if post_auth_success
      status 204
    else
      status 404
    end
  end

  get '/logging/post-auth/user/?:username?/cert-name/?:cert_name?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result' do
    post_auth_success = Logging::PostAuth.new.execute(params: params)

    if post_auth_success
      status 204
    else
      status 404
    end
  end
end
