module Logging
  class PostAuth
    def execute(params:)
      authentication_result = params.fetch(:authentication_result)

      if authentication_result == 'Access-Accept'
        handle_access_accept(params)
        return true
      elsif authentication_result == 'Access-Reject'
        return true
      end

      false
    end

  private

    def handle_access_accept(params)
      username = params.fetch(:username)
      return if username == 'HEALTH'

      create_session(params)
      update_user_last_login(username)
    end

    def create_session(params)
      Session.create(
        username: params.fetch(:username),
        mac: formatted_mac(params.fetch(:mac)),
        ap: params.fetch(:called_station_id),
        siteIP: params.fetch(:site_ip_address),
        building_identifier: params.fetch(:called_station_id),
      )
    end

    def update_user_last_login(username)
      user = User.find(username: username)
      return unless user

      user.last_login = Time.now.strftime('%y-%m-%d %H:%M:%S')
      user.save
    end

    def formatted_mac(unformatted_mac)
      MacFormatter.new.execute(mac: unformatted_mac)
    end
  end
end
