require 'sequel'
require 'sinatra/base'
require './lib/mac_formatter.rb'
require './lib/session.rb'

class App < Sinatra::Base
  get '/healthcheck' do
    'Healthy'
  end

  get '/logging/post-auth/user/:username/mac/:mac/ap/:called_station_id/site/:site_ip_address/*' do
    Session.create(
      username: params.fetch(:username),
      mac: params.fetch(:mac),
      ap: params.fetch(:called_station_id),
      siteIP: params.fetch(:site_ip_address),
      building_identifier: params.fetch(:called_station_id),
    )
  end
end
