require 'logger'
logger = Logger.new(STDOUT)

task :daily_session_deletion do
  session_gateway = Gdpr::Gateway::Session.new
  Gdpr::UseCase::SessionDeletion.new(session_gateway: session_gateway).execute

  logger.info('Daily Session Deletion Ran')
end
