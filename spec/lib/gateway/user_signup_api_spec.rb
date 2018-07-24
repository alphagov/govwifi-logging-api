describe Gateway::UserSignupApi do
  let(:user_signup_host) { 'https://localhost' }
  let(:record_last_login_stub) { stub_request(:post, "#{user_signup_host}/user-signup/record-last-login") }

  before do
    ENV['USER_SIGNUP_API_BASE_URL'] = user_signup_host
    stub_request(:post, "#{user_signup_host}/user-signup/record-last-login")
  end

  describe 'record_last_login' do
    let(:time) { Time.new(2018, 7, 24, 11, 25, 40, "+00:00") }

    it 'posts the username and datetime to the user-signup-api' do
      subject.record_last_login(username: 'adrian', datetime: time)
      expect(
        record_last_login_stub.with(
          body: "username=adrian&datetime=2018-07-24T11%3A25%3A40%2B00%3A00"
        )
      ).to have_been_requested.times(1)
    end
  end
end
