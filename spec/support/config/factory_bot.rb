require 'factory_bot_rails'

FactoryBot.definition_file_paths.unshift(CertWatch::Engine.root.join('spec', 'factories'))

RSpec.configure do |config|
  # Allow to use build and create methods without FactoryBot prefix.
  config.include FactoryBot::Syntax::Methods

  # Make sure factories are up to date when using spring
  config.before(:all) do
    FactoryBot.reload
  end
end
