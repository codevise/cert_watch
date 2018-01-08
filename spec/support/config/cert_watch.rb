require 'support/helpers/doubles'

RSpec.configure do |config|
  config.before do
    CertWatch.setup
    CertWatch.client = Doubles.client
    CertWatch.installer = Doubles.installer
  end
end
