class LastLoginSync::Gateway::Activity
  def since(date:)
    sessions = Session.select(:username).where {
      start < date.next_day
    }.where {
      start >= date
    }.distinct(:username)
    sessions.map(&:username)
  end
end
