class Gdpr::Gateway::SetLastLogin
  def set(date:, usernames:)
    usernames.each_slice(100) do |_username_slice|
      User
        .where([[:username, usernames]])
        .update(last_login: date)
    end
  end
end
