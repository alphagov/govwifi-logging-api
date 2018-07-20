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

    VALID_MAC_LENGTH = 17

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
        ap: ap(params.fetch(:called_station_id)),
        siteIP: params.fetch(:site_ip_address),
        building_identifier: building_identifier(params.fetch(:called_station_id))
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

    def valid_mac?(mac)
      mac.to_s.length == VALID_MAC_LENGTH
    end

    def building_identifier(called_station_id)
      called_station_id if !valid_mac?(formatted_mac(called_station_id))
    end

    def ap(unformatted_mac)
      mac = formatted_mac(unformatted_mac)
      return mac if valid_mac?(mac)
      ''
    end
  end
end
