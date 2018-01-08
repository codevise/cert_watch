# CHANGELOG

### Unreleased Changes

[Compare changes](https://github.com/codevise/cert_watch/compare/1-x-stable...master)

##### Breaking Changes

- Certificates are now stored in database

  This allows recreating certificates on disk when creating new application
  instances.

  To adapt the database schema, install migrations and migrate:

  ```
  bundle exec rake cert_watch:install:migrations
  bundle exec rake db:migrate
  ```

  Ensure private keys are filtered in parameter logging:

  ```ruby
  # config/initializers/filter_parameter_logging.rb
  Rails.application.config.filter_parameters += [:private_key]
  ```

  Installed certificates previously created by Certbot can be imported
  by adding to following line the application's `Rakefile`:

  ```ruby
  require 'cert_watch/tasks'
  ```

  and running

  ```
  bundle exec rake cert_watch:import:certbot
  ```
  ([#1](https://github.com/codevise/cert_watch/pull/1))

##### New Features

- Custom certificates can now be managed manually via the admin
  interface. ([#1](https://github.com/codevise/cert_watch/pull/1))

- Custom and certbot generated certifiactes can be stored in separate
  directories via the `provider_install_directory_mapping` config
  option. ([#1](https://github.com/codevise/cert_watch/pull/1))

See
[1-x-stable branch](https://github.com/codevise/cert_watch/blob/1-x-stable/CHANGELOG.md)
for previous changes.
