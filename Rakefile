begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks

require 'semmy'
Semmy::Tasks.install

task default: :spec
