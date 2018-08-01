# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require 'combustion'
Combustion.initialize! :all

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'support/config/factory_bot'
require 'support/config/timecop'
require 'support/config/cert_watch'

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.when_first_matching_example_defined(perform_jobs: true) do
    require 'support/helpers/perform_jobs'
  end

  config.when_first_matching_example_defined(fixture_files: true) do
    require 'support/helpers/fixtures'
  end

  config.when_first_matching_example_defined(type: :view_component) do
    require 'support/helpers/view_component_example_group'
  end
end
