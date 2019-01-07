#\ --quiet

RACK_ENV = ENV['RACK_ENV'] ||= 'development'

require 'sensible_logging'
require './app'

run sensible_logging(
  app: App,
  logger: Logger.new(STDOUT)
)
