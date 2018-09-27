module Logging
  class PostAuth
    def execute(params:)
      valid_request?(params) ? handle_access_request(params) : false
    end

  private

    VALID_MAC_LENGTH = 17

    def valid_request?(params)
      valid_auth_results = ['Access-Accept', 'Access-Reject']
      auth_result = params.fetch(:authentication_result)
      valid_auth_results.include?(auth_result)
    end

    def handle_access_request(params)
      username = params.fetch(:username)
      return true if username == 'HEALTH'

      update_user_last_login(username)
      create_session(params)
    end

    def create_session(params)
      Session.create(
        start: Time.now,
        username: username(params.fetch(:username)),
        mac: formatted_mac(params.fetch(:mac)),
        ap: ap(params.fetch(:called_station_id)),
        siteIP: params.fetch(:site_ip_address),
        building_identifier: building_identifier(params.fetch(:called_station_id))
      )
    end

    def update_user_last_login(username)
      user = User.find(username: username)
      return unless user

      user.last_login = Time.now
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

    def username(unformatted_username)
      unformatted_username.to_s.upcase
    end

    def ap(unformatted_mac)
      mac = formatted_mac(unformatted_mac)
      return mac if valid_mac?(mac)

      ''
    end
  end
end
