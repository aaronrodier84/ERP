require 'simplecov'
SimpleCov.start do
 add_filter "/test/"
 add_filter "/config/"
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
Rails.application.eager_load!

require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara-screenshot/minitest'

Minitest.parallel_executor = Minitest::Parallel::Executor.new(5)

Dir[Rails.root.join('test/support/**/*.rb')].each { |file| require file }

reporter_options = { color: true, slow_count: 10 }
reporter = Minitest::Reporters::DefaultReporter.new reporter_options
Minitest::Reporters.use! reporter

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

Capybara.javascript_driver = :poltergeist
Capybara::Screenshot.prune_strategy = :keep_last_run

# ! For proper test configuration, ActionDispatch::IntegrationTest hooks 
# should go ABOVE ActiveSupport::TestCase hooks.
class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  before do
    # Enabling JS driver in all integration tests by default.
    Capybara.current_driver = Capybara.javascript_driver
    # JS driver is incompatible with fast :transaction DatabaseCleaner strategy.
    # So only for integration tests, we are using slow :truncation strategy.
    DatabaseCleaner.strategy = :truncation
  end

  after do
    # Switch back to :transaction for the next test.
    DatabaseCleaner.strategy = :transaction
    Capybara.reset_sessions!
    # Switch back to non-JS driver.
    Capybara.use_default_driver
  end
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  self.use_transactional_fixtures = false
  
  before do
    # If this is an integration test, the related "before" hook 
    # has already set up a proper DatabaseCleaner strategy by this moment.
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end

# More hooks for ActionDispatch::IntegrationTest data creation and log in.
# These should go AFTER DatabaseCleaner-related ActiveSupport::TestCase hooks.
class ActionDispatch::IntegrationTest
  before do
    populate_zones
    login_user
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end


require 'mocha/mini_test'


