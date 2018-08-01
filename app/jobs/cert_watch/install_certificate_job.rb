module CertWatch
  class InstallCertificateJob < CertWatch::ApplicationJob
    queue_as :cert_watch

    include StateMachineJob

    def perform_with_result(certificate, _options = {})
      CertWatch.installer.install(domain: certificate.domain,
                                  provider: certificate.provider,
                                  public_key: certificate.public_key,
                                  private_key: certificate.private_key,
                                  chain: certificate.chain)

      certificate.last_installed_at = Time.now

      :ok
    rescue InstallError
      certificate.last_install_failed_at = Time.now
      :error
    end
  end
end
