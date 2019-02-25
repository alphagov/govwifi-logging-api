module Logging
  class PostAuth
    def execute(params:)
      @params = params

      return handle_username_request unless @params['cert_name'].present?

      create_cert_session
    end

  private

    def create_user_session
      if invalid_username?(username)
        handle_invalid_username
      else
        Session.create(session_params.merge(username: username.to_s.upcase))
      end
    end

    def invalid_username?(username)
      username.to_s.length > 6
    end

    def handle_invalid_username
      puts "#{username} was invalid due to being longer than 6 characters, logging rejected"
    end

    def create_cert_session
      Session.create(
        session_params.merge(
          cert_name: @params.fetch('cert_name')
        )
      )
    end

    def session_params
      {
        start: Time.now,
        mac: @params.fetch('mac'),
        ap: @params.fetch('called_station_id'),
        siteIP: @params.fetch('site_ip_address'),
        building_identifier: @params.fetch('called_station_id'),
        success: access_accept?
      }
    end

    def update_user_last_login
      User.where(username: username).update(last_login: Time.now)
    end

    def access_reject?
      @params.fetch('authentication_result') == 'Access-Reject'
    end

    def access_accept?
      @params.fetch('authentication_result') == 'Access-Accept'
    end

    def username
      @params.fetch('username')
    end

    def handle_username_request
      return true if username == 'HEALTH'

      update_user_last_login unless access_reject?
      create_user_session
    end
  end
end
