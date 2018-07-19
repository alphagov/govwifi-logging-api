require 'sequel'
require 'sinatra/base'
require './lib/mac_formatter.rb'
require './lib/session.rb'
require './lib/user.rb'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
  end

  get '/healthcheck' do
    'Healthy'
  end

  get '/logging/post-auth/user/:username/mac/:mac/ap/:called_station_id/site/:site_ip_address/result/:authentication_result' do
    if params.fetch(:authentication_result) == 'Access-Accept'
      if params.fetch(:username) != 'HEALTH'
        mac = MacFormatter.new.execute(mac: params.fetch(:mac))
        Session.create(
          username: params.fetch(:username),
          mac: mac,
          ap: params.fetch(:called_station_id),
          siteIP: params.fetch(:site_ip_address),
          building_identifier: params.fetch(:called_station_id),
        )
        user = User.find(username: params.fetch(:username))
        user.last_login = Time.now.strftime('%y-%m-%d %H:%M:%S')
        user.save
      end

      status 204
    elsif params.fetch(:authentication_result) == 'Access-Reject'
      status 204
    else
      status 404
    end
  end
end
