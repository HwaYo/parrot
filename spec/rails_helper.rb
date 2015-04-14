# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'acceptance_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  # config.include FactoryGirl::Syntax::Methods
  FactoryGirl.lint

  # Acceptance Helper Mixin
  config.include AcceptanceHelper

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => 'default')
  end
  # Type `CAPYBARA_DRIVER=selenium bundle exec rspec acceptance` for acceptance testing
  Capybara.default_driver = ENV.fetch('CAPYBARA_DRIVER', :rack_test).to_sym

  config.use_transactional_fixtures = false
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end

  config.infer_spec_type_from_file_location!

  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:facebook, {:uid => '1234512345'})
end
