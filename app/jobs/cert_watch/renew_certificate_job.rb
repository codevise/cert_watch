module CertWatch
  class RenewCertificateJob
    extend StateMachineJob

    @queue = :cert_watch

    def self.perform_with_result(certificate, _options = {})
      CertWatch.client.renew(certificate.domain)
      certificate.last_renewed_at = Time.now
      :ok
    rescue RenewError
      certificate.last_renewal_failed_at = Time.now
      fail
    end
  end
end
