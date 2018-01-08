module CertWatch
  class RenewExpiringCertificatesJob
    @queue = :cert_watch

    def self.perform
      Certificate
        .auto_renewable
        .installed
        .expiring
        .limit(CertWatch.config.renewal_batch_size)
        .each(&:renew)
    end
  end
end
