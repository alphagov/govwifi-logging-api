#\ --quiet
# The above is needed to prevent rack from logging

RACK_ENV = ENV['RACK_ENV'] ||= 'development'

require './app'
run App
