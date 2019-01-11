task :daily_session_deletion do
  session_gateway = Gdpr::Gateway::Session.new
  Gdpr::UseCase::SessionDeletion.new(session_gateway: session_gateway).execute
end
