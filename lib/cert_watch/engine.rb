require 'state_machines-activerecord'
require 'state_machine_job'

module CertWatch
  class Engine < ::Rails::Engine
    isolate_namespace CertWatch

    config.paths.add('lib', eager_load: true)
  end
end
