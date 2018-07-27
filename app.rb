require 'sequel'
require 'sinatra/base'
require './lib/loader'
require './lib/mac_formatter.rb'
require './lib/session.rb'
require './lib/user.rb'
require './lib/logging/post_auth.rb'
require './lib/performance_platform/gateway/account_usage.rb'
require './lib/performance_platform/repository/session.rb'
require './lib/performance_platform/use_case/send_performance_report'
require './lib/performance_platform/presenter/account_usage'
require './lib/common/base64'
require './lib/performance_platform/gateway/performance_report'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
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
end
