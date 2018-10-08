require 'sequel'
require 'sinatra/base'
require 'sinatra/json'
require './lib/loader'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
    enable :json
  end

  get '/healthcheck' do
    'Healthy'
  end

  get '/auth_requests/search/ip/:ip_address' do
    ip_address = params[:ip_address]
    sessions = Session.where(siteIP: ip_address).reverse_order(:start).limit(100)

    json sessions.map(&:to_hash)
  end

  get '/logging/post-auth/user/?:username?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result' do
    post_auth_success = Logging::PostAuth.new.execute(params: params)

    if post_auth_success
      status 204
    else
      status 404
    end
  end
end
