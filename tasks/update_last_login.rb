require 'date'

task :update_yesterdays_last_login do
  LastLoginSync::UseCase::PopulateUserLastLogin.new(
    active_users_gateway: LastLoginSync::Gateway::Activity.new,
    last_login_gateway: LastLoginSync::Gateway::SetLastLogin.new
  ).execute(date: Date.today.prev_day)
end

task :update_last_login, [:date] do |_, args|
  args.with_defaults(date: Date.today.to_s)
  date = Date.parse(args[:date])

  LastLoginSync::UseCase::PopulateUserLastLogin.new(
    active_users_gateway: LastLoginSync::Gateway::Activity.new,
    last_login_gateway: LastLoginSync::Gateway::SetLastLogin.new
  ).execute(date: date)
end
