module Logging
  class PostAuth
    def execute(params:)
      @params = params

      return true if username == 'HEALTH'

      return false unless access_accept? || access_reject?

      if access_accept?
        update_user_last_login
        create_session
      end
    end

  private

    VALID_MAC_LENGTH = 17

    def create_session
      Session.create(
        start: Time.now,
        username: username.to_s.upcase,
        mac: formatted_mac(@params.fetch(:mac)),
        ap: ap(@params.fetch(:called_station_id)),
        siteIP: @params.fetch(:site_ip_address),
        building_identifier: building_identifier(@params.fetch(:called_station_id))
      )
    end

    def update_user_last_login
      user = User.find(username: username)
      return unless user

      user.last_login = Time.now
      user.save
    end

    def access_reject?
      @params.fetch(:authentication_result) == 'Access-Reject'
    end

    def access_accept?
      @params.fetch(:authentication_result) == 'Access-Accept'
    end

    def username
      @params.fetch(:username)
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
