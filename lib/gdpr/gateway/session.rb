require 'logger'

class Gdpr::Gateway::Session
  def delete_sessions
    logger = Logger.new(STDOUT)

    logger.info('Starting daily session deletion')

    rows = Session.where(Sequel.lit('start < DATE_SUB(DATE(NOW()), INTERVAL 32 DAY')).count

    i = 0
    while i < rows
      Session.where(Sequel.lit('start < DATE_SUB(DATE(NOW()), INTERVAL 32 DAY')).limit(100, i).delete
      i += 100
    end

    logger.info("Finished daily session deletion, #{rows} rows affected")
  end

  def active_users(date:)
    Session.select(:username).distinct
      .where(Sequel.lit('DATE(start) = ?', date))
      .map(:username)
  end
end
