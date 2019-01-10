class Gdpr::Gateway::Session
  def delete_sessions
    DB.run('DELETE FROM sessions WHERE start < DATE_SUB(DATE(NOW()), INTERVAL 32 DAY)')
  end
end
