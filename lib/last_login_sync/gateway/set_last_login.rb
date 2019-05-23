class LastLoginSync::Gateway::SetLastLogin
  def set(date:, usernames:)
    usernames.each_slice(100) do |username_slice|
      User
        .where([[:username, usernames]])
        .where{ (last_login =~ nil) | (last_login < date) }
        .update(last_login: date)
    end
  end
end
