# CertWatch

[![Gem Version](https://badge.fury.io/rb/cert_watch.svg)](http://badge.fury.io/rb/cert_watch)
[![Dependency Status](https://gemnasium.com/badges/github.com/codevise/cert_watch.svg)](https://gemnasium.com/github.com/codevise/cert_watch)
[![Build Status](https://travis-ci.org/codevise/cert_watch.svg?branch=master)](https://travis-ci.org/codevise/cert_watch)
[![Coverage Status](https://coveralls.io/repos/github/codevise/cert_watch/badge.svg?branch=master)](https://coveralls.io/github/codevise/cert_watch?branch=master)
[![Code Climate](https://codeclimate.com/github/codevise/cert_watch/badges/gpa.svg)](https://codeclimate.com/github/codevise/cert_watch)

A Rails engine to manage and automatically obtain, install and renew
SSL certificates.

## Ingredients

CertWatch consists of the following components:

* Resque jobs to renew and install certificates.
* A mixin for models with a `cname` attribute to request certificats
  on attribute change.
* Rake tasks to reinstall certificates on a fresh server

Optionally:

* An Active Admin resource to manage certificates.
* An Arbre view component to display certificate status for a given
  domain.

## Requirements

* Rails 4
* [Resque](https://github.com/resque/resque)
* [Resque Scheduler](https://github.com/resque/resque-scheduler)
* [Resque Logger](https://github.com/salizzar/resque-logger)
* [Certbot](https://certbot.eff.org/)

## Limitations

* Requires `sudo` on the server. The `certbot` script used to obtain
  certificates needs root priviledges. This could probably be avoided
  by using the
  [`acme-client` gem](https://github.com/unixcharles/acme-client)
  instead.
* Works only with webservers that can read certificates from a
  directory (Tested with HAProxy).

## Installation

Add the following lines to your `Gemfile` and run `bundle install`:

```ruby
gem 'cert_watch'

# Required since state_machine gem is unmaintained
gem 'state_machine', git: 'https://github.com/codevise/state_machine.git'
```

Add an initializer:

```ruby
# config/initializers/cert_watch.rb
CertWatch.setup do |config|
  # Uncomment any of the below options to change the default

  # Maximum age of certificates before renewal.
  # config.renewal_interval = 1.month

  # Number of expiring certificates to renew in one run of the
  # `RenewExpiringCertificatesJob`.
  # config.renewal_batch_size = 10

  # File name of the certbot executable.
  # config.certbot_executable = '/usr/local/share/letsencrypt/bin/certbot'

  # Port for the standalone certbot HTTP server
  # config.certbot_port = 9999

  # Directory certbot outputs certificates to
  # config.certbot_output_directory = '/etc/letsencrypt/live'

  # Directory the web server reads pem files from
  # config.pem_directory = '/etc/haproxy/ssl/'

  # Place pem files in provider specific subdirectories of pem directory.
  # By default, all pem files are placed in pem directory itself.
  # config.provider_install_directory_mapping = {
  #   certbot: 'letsencrypt',
  #   custom: 'custom'
  # }

  # Command to make server reload pem files
  # config.server_reload_command = '/etc/init.d/haproxy reload'
end
```

Ensure private keys do not show up in log files:

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [:private_key]
```

Include the `DomainOwner` mixin into a model with a domain
attribute. This makes CertWatch obtain or renew certificates whenever
the attribute changes. Validation has to be provided by the host
application.

```ruby
# app/models/account.rb
# assuming Account has a cname attribute
class Account
  include CertWatch.domain_owner(attribute: :cname)
end
```

If you want to use the Active Admin resource, add the following line
to the top of your Active Admin initializer:

```ruby
# config/initializers/active_admin.rb
ActiveAdmin.application.load_paths.unshift(CertWatch.active_admin_load_path)
```

If you use the CanCan authorization adapter, you also need to add the
following rule for users that should be allowed to manage certificats:

```ruby
# app/models/ability.rb
can :manage, CertWatch::Certificate
```

Now install migrations and migrate your database:

```
$ bin/rake cert_watch:install:migrations
$ bin/rake db:migrate
```

Setup your `resque_schedule.yml` to check for expiring certificates:

```
# config/resque_schedule.yml
fetch_billed_traffic_usages:
  every:
    - "5h"
    - :first_in: "1m"
  class: "CertWatch::RenewExpiringCertificatesJob"
  queue: cert_watch
  description: "Check for expiring SSL certificates"
```

Finally ensure Resque workers have been assigned to the `cert_watch`
queue.

## Rake Tasks

Add the following line to your application's `Rakefile`:

```ruby
# Rakefile
require 'cert_watch/tasks'
```

To reinstall all certificates (i.e. on a new server), run:

```
$ bin/rake cert_watch:reinstall:all
```

## Active Admin View Components

You can render a status tag displaying the current certificate state
for a given domain:

```ruby
# app/admin/dashboard.rb
require 'cert_watch/views/certificate_state'

div(class: 'account_cname') do
  text_node(account.cname)
  cert_watch_certificate_state(account.cname)
end
```

## Troubleshooting

If you run into problems or want to discuss a feature request, please
[file an issue](https://github.com/codevise/cert_watch/issues?state=open).
