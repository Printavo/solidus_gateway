require "simplecov"
SimpleCov.start("rails")

require "capybara/rspec"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "rspec/rails"
require "database_cleaner"

# solidus_dev_support is dropped: its 'master' git branch no longer exists and the
# released gem pins rspec-rails < 7.0 (unsatisfiable here). It only supplied the
# feature/preferences helpers below, which the solidus fork already ships under
# spree/testing_support — so we require those directly.
require "spree/testing_support/preferences"
require "spree/testing_support/url_helpers"
require "spree/testing_support/controller_requests"

# NOTE: no upstream equivalent — we intentionally do NOT call
# ActiveRecord::Migration.maintain_test_schema! here. The gateway engine's migrations
# are copied into the dummy (with new timestamps + a "comes from solidus_gateway"
# marker) by rake test_app, but maintain_test_schema! reloads db/schema.rb and then
# re-checks pending against the engine's *original* timestamps, reporting them as
# perpetually pending. rake test_app already migrates the dummy fully, so we rely on
# that instead. (Equivalent in spirit to disabling maintain_test_schema for engines.)

# Permit the classes serialized into Spree fixtures/factories (e.g. :order_with_line_items)
# so Psych::DisallowedClass is not raised under Rails' safe YAML loader
# (mirrors solidusio/solidus#4451).
ActiveRecord.yaml_column_permitted_classes |= [BigDecimal, Date, Symbol, Time]

# Feature specs need a browser stack; guard the driver registration so the
# (non-feature) model suite still loads on machines without selenium/chrome.
begin
  require "selenium-webdriver"

  Capybara.register_driver(:selenium_chrome_headless) do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << "--window-size=1024,768"
    browser_options.args << "--enable-features=NetworkService,NetworkServiceInProcess"
    browser_options.args << "--no-sandbox"
    browser_options.args << "--disable-dev-shm-usage"
    browser_options.args << "--headless"
    browser_options.args << "--disable-gpu"

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = 90

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      http_client: client,
      options: browser_options
    )
  end

  Capybara.javascript_driver = :selenium_chrome_headless
rescue LoadError
  # No browser stack available; feature specs will be skipped/error, model specs still run.
end

require "braintree"

require "spree/testing_support/factory_bot"
Spree::TestingSupport::FactoryBot.add_paths_and_load!

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  # The gateway specs call bare create(:country) etc.; solidus_dev_support used to
  # mix in FactoryBot::Syntax::Methods globally, so do it explicitly now that it's gone.
  config.include FactoryBot::Syntax::Methods

  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    # Don't log Braintree to STDOUT.
    Braintree::Configuration.logger = Logger.new("spec/dummy/tmp/log")
  end

  config.after do
    DatabaseCleaner.clean
  end
end
