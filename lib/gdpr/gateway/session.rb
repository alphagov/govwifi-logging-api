require 'logger'

class Gdpr::Gateway::Session
  def delete_sessions
    logger = Logger.new(STDOUT)

    logger.info('Starting daily session deletion')

    dataset = DB['DELETE FROM sessions WHERE start < DATE_SUB(DATE(NOW()), INTERVAL 32 DAY)']
    rows_affected = dataset.delete

    logger.info("Finished daily session deletion, #{rows_affected} rows affected")
  end

  def active_users(date:)
    Session.select(:username).distinct
      .where(Sequel.lit('DATE(start) = ?', date))
      .map(:username)
  end
end
