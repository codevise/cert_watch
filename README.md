# CertWatch

A Rails engine to manage and automatically obtain, install and renew
SSL certificates.

## Ingredients

CertWatch consists of the following components:

* Resque jobs to renew and install certificates.
* A mixin for models with a `cname` attribute to request certificats
  on attribute change.

Optionally:

* An Active Admin resource to manage certificates.
* An Arbre view component to display certificate status for a given
  domain.

## Requirements

* Rails 4
* Resque
* Resque Scheduler
* Resque Logger

## Installation

Add the following lines to your `Gemfile` and run `bundle install`:

    gem 'cert-watch'

    # Required since state_machine gem is unmaintained
    gem 'state_machine', git: 'https://github.com/codevise/state_machine.git'

Add an initializer:

    # config/initializers/cert_watch.rb
    CertWatch.setup do |config|
      # ...
    end

See [`CertWatch::Documentation`]() for a list of available config
options.

Include the `DomainOwner` mixin into a model with a domain
attribute. This makes CertWatch obtain or renew certificates whenever
the attribute changes. Validation has to be provided by the host
application.

    # app/models/account.rb
    # assuming Account has a cname attribute
    class Account
      include CertWatch.domain_owner(attribute: :cname)
    end

If you want to use the Active Admin resource, add the following line
to the top of your Active Admin initializer:

    # config/initializers/active_admin.rb
    ActiveAdmin.application.load_paths.unshift(CertWatch.active_admin_load_path)

Now install migrations and migrate your database:

    $ bin/rake cert_watch:install:migrations
    $ bin/rake db:migrate

Setup your `resque_schedule.yml` to check for expiring certificates:

    # config/resque_schedule.yml
    fetch_billed_traffic_usages:
      every:
        - "5h"
        - :first_in: "1m"
      class: "CertWatch::RenewExpiringCertificatesJob"
      queue: cert_watch
      description: "Check for expiring SSL certificates"

Finally ensure Resque workers have been assigned to the `cert_watch`
queue.

## Active Admin View Components

You can render a status tag displaying the current certificate state
for a given domain:

    # app/admin/dashboard.rb
    require 'cert_watch/views/certificate_state'

    div(class: 'account_cname') do
      text_node(account.cname)
      cert_watch_certificate_state(account.cname)
    end
