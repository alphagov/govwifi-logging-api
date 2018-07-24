module Gateway
  class UserSignupApi
    def record_last_login(username:, datetime:)
      uri = URI("#{ENV.fetch('USER_SIGNUP_API_BASE_URL')}/user-signup/record-last-login")
      request = Net::HTTP::Post.new(uri)
      request.body = URI.encode_www_form(username: username, datetime: datetime.iso8601)

      Net::HTTP.start(uri.hostname, 443, use_ssl: true) do |http|
        http.request(request)
      end
      nil
    end
  end
end
