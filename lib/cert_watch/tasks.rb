require 'rake'

module CertWatch
  module Tasks
    extend Rake::DSL

    namespace :cert_watch do
      namespace reinstall: :environment do
        desc 'Rewrite certificate files from database contents.'
        task :all do
          Certificate.installed.each(&:install)
        end
      end

      namespace :import do
        desc 'Read certbot outputs for all certificates and store in database.'
        task certbot: :environment do
          Certificate.auto_renewable.installed.each do |certificate|
            result = CertWatch.client.read_outputs(certificate.domain)
            certificate.update!(result.slice(:public_key, :private_key, :chain))
          end
        end
      end
    end
  end
end
