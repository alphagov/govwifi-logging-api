class Smoketests::SmoketestCleanup
  SESSION_BATCH_SIZE = 50
  def clean
    logger = Logger.new($stdout)
    logger.info("Starting daily smoke test user and session deletion")

    total = 0
    while (users = next_batch_of_users).count.positive?
      Session.where(username: users.select_map(:username)).delete
      total += users.delete
    end

    logger.info("Finished daily smoke test user deletion, #{total} rows affected")
  end

private

  def next_batch_of_users
    User
      .where { contact.like "govwifi-tests+%@digital.cabinet-office.gov.uk" }
      .where { created_at < Time.now - (10 * 60) }
      .limit(SESSION_BATCH_SIZE)
  end
end
