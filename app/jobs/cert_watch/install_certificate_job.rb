module CertWatch
  class InstallCertificateJob
    extend StateMachineJob

    @queue = :cert_watch

    def self.perform_with_result(certificate, _options = {})
      CertWatch.installer.install(certificate.domain)
      certificate.last_installed_at = Time.now
      :ok
    rescue InstallError
      certificate.last_install_failed_at = Time.now
      fail
    end
  end
end
