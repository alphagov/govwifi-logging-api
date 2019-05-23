require 'date'

class LastLoginSync::UseCase::PopulateUserLastLogin
  def initialize(active_users_gateway:, last_login_gateway:)
    @active_users = active_users_gateway
    @last_login_gateway = last_login_gateway
  end

  def execute(date: Date.today)
    usernames = active_users.since(date: date)
    last_login_gateway.set(date: date, usernames: usernames)
  end

private

  attr_reader :active_users, :last_login_gateway
end
