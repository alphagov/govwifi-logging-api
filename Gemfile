source "http://rubygems.org"
ruby File.read(".ruby-version").chomp

gem "aws-sdk-s3"
gem "elasticsearch", "~> 7.17.10"
gem "faraday"
gem "mysql2"
gem "puma"
gem "rake"
gem "require_all"
gem "rexml"
gem "sensible_logging"
gem "sentry-ruby"
gem "sequel"
gem "sinatra"
gem "sinatra-contrib"

group :test do
  gem "factory_bot"
  gem "rack-test"
  gem "rspec"
  gem "rubocop-govuk"
  gem "simplecov"
  gem "timecop"
  gem "webmock"
end

group :vscodedev do
  gem "debase", ">= 0.2.5.beta2"
  gem "ruby-debug-ide"
  gem "solargraph"
end
