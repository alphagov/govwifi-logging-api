require 'sequel'
require 'sinatra/base'
require './lib/mac_formatter.rb'

class App < Sinatra::Base
  get '/healthcheck' do
    'Healthy'
  end

  get '/logging/post-auth/*' do
    ''
  end
end
