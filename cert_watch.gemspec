$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'cert_watch/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'cert_watch'
  s.version     = '2.0.1.dev'
  s.authors     = ['Tim Fischbach']
  s.email       = ['tfischbach@codevise.de']
  s.summary     = 'Rails engine for automatically renewing SSL certificates.'
  s.homepage    = 'https://github.com/codevise/cert_watch'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  # Rails engine bindings
  s.add_dependency 'rails', '~> 5.2.0'

  # Resque jobs and queues
  s.add_dependency 'resque', '~> 1.25'

  # State machines for active record
  s.add_dependency 'state_machines-activerecord', '~> 0.5.1'

  # Trigger resque jobs with a state machine
  s.add_dependency 'state_machine_job', '~> 3.0'

  # Testing framework
  s.add_development_dependency 'rspec-rails', '~> 3.7'

  # Fixture data
  s.add_development_dependency 'factory_bot_rails', '~> 4.8'

  # Freeze time in tests
  s.add_development_dependency 'timecop', '~> 0.7.1'

  # Dummy Rails app helper
  s.add_development_dependency 'combustion', '~> 0.9.1'

  # Database for test application
  s.add_development_dependency 'sqlite3'

  # Admin engine. Optional runtime dependency
  s.add_development_dependency 'activeadmin', '~> 1.0'

  # Browser integration testing
  s.add_development_dependency 'capybara', '~> 3.4'

  # Semantic versioning rake tasks
  s.add_development_dependency 'semmy', '~> 1.0'
end
