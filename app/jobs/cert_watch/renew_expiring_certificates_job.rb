module CertWatch
  class RenewExpiringCertificatesJob < CertWatch::ApplicationJob
    queue_as :cert_watch

    def perform
      Certificate
        .auto_renewable
        .installed
        .expiring
        .limit(CertWatch.config.renewal_batch_size)
        .each(&:renew)
    end
  end
end
