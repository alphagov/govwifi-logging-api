RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)

require 'sequel'

DB = Sequel.connect(
  adapter: 'mysql2',
  host: ENV.fetch('DB_HOSTNAME'),
  database: ENV.fetch('DB_NAME'),
  user: ENV.fetch('DB_USER'),
  password: ENV.fetch('DB_PASS')
)

require './app'
run App
