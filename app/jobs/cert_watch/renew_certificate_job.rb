module CertWatch
  class RenewCertificateJob < CertWatch::ApplicationJob
    queue_as :cert_watch

    include StateMachineJob

    def perform_with_result(certificate, _options = {})
      result = CertWatch.client.renew(certificate.domain)

      certificate.attributes = result.slice(:public_key, :private_key, :chain)
      certificate.last_renewed_at = Time.now

      :ok
    rescue RenewError
      certificate.last_renewal_failed_at = Time.now
      :error
    end
  end
end
