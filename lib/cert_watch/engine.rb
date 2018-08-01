require 'state_machines-activerecord'
require 'state_machine_job'

module CertWatch
  class Engine < ::Rails::Engine
    isolate_namespace CertWatch

    config.autoload_paths << File.join(config.root, 'lib')
  end
end
