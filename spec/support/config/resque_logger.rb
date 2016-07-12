require 'fileutils'
log_dir = Rails.root.join('log', 'jobs', Rails.env)

RSpec.configure do |config|
  config.before(:all) do
    FileUtils.mkdir_p(log_dir)
  end
end

Resque.logger_config = {
  folder: log_dir,
  class_name: Logger,
  class_args: ['daily', 1.kilobyte],
  level:      Logger::INFO,
  formatter:  Logger::Formatter.new
}
