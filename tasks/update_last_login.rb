require 'date'

task :update_yesterdays_last_login do
  Gdpr::UseCase::PopulateUserLastLogin.new(
      session_gateway: Gdpr::Gateway::Session.new,
      last_login_gateway: Gdpr::Gateway::SetLastLogin.new
  ).execute(date: Date.today.prev_day)
end
