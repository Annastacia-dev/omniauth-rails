source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0.4"
gem "sprockets-rails"
gem "pg"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "font-awesome-sass", "~> 6.2.1"
gem 'bcrypt'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'dotenv-rails'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-facebook', '~> 10.0'
gem 'omniauth-github'
gem 'omniauth-twitter2'
gem 'omniauth-linkedin-oauth2', '~> 1.0', '>= 1.0.1'


group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "byebug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
