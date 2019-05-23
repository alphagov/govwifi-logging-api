require 'date'

task :update_last_login, [:date] do |_, args|
  args.with_defaults(date: Date.today.to_s)

  if args[:date] == 'yesterday'
    date = Date.today.prev_day
  else
    date = args[:date].to_date
  end

  LastLoginSync::UseCase::PopulateUserLastLogin.new(
    active_users_gateway: LastLoginSync::Gateway::Activity.new,
    last_login_gateway: LastLoginSync::Gateway::SetLastLogin.new
  ).execute(date: date)
end
