class LastLoginSync::Gateway::Activity
  def since(date:)
    Session.select(:username).distinct
      .where(Sequel.lit('DATE(start) = ?', date))
      .map(:username)
  end
end
