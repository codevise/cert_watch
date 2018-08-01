RSpec.configure do |config|
  config.before(:each) do |example|
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs =
      example.metadata[:perform_jobs]
  end
end
