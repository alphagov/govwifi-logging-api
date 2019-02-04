module Logging
  class PostAuth
    def execute(params:)
      @params = params

      return handle_username_request unless @params[:cert_name]

      create_cert_session
    end

  private

    VALID_MAC_LENGTH = 17

    def create_user_session
      Session.create(session_params.merge(username: username.to_s.upcase))
    end

    def create_cert_session
      Session.create(
        session_params.merge(
          cert_name: @params.fetch(:cert_name)
        )
      )
    end

    def session_params
      {
        start: Time.now,
        mac: formatted_mac(@params.fetch(:mac)),
        ap: ap(@params.fetch(:called_station_id)),
        siteIP: @params.fetch(:site_ip_address),
        building_identifier: building_identifier(@params.fetch(:called_station_id)),
        success: access_accept?
      }
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

    def handle_username_request
      return true if username == 'HEALTH'

      update_user_last_login unless access_reject?
      create_user_session
    end
  end
end
