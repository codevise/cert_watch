require 'rails_helper'

require 'support/helpers/perform_jobs'

module CertWatch
  RSpec.describe RenewExpiringCertificatesJob do
    it 'triggers renewal of installed expiring certificates' do
      certificate = create(:certificate, state: 'installed', last_renewed_at: 40.days.ago)
      CertWatch.config.renewal_interval = 1.month

      RenewExpiringCertificatesJob.perform_now

      expect(certificate.reload.state).to eq('renewing')
    end

    it 'ignores uninstalled certificates' do
      certificate = create(:certificate, state: 'abandoned', last_renewed_at: 40.days.ago)
      CertWatch.config.renewal_interval = 1.month

      RenewExpiringCertificatesJob.perform_now

      expect(certificate.reload.state).to eq('abandoned')
    end

    it 'ignores not expiring certificates' do
      certificate = create(:certificate, state: 'installed', last_renewed_at: 10.days.ago)
      CertWatch.config.renewal_interval = 1.month

      RenewExpiringCertificatesJob.perform_now

      expect(certificate.reload.state).to eq('installed')
    end

    it 'limits number of renewed certificates to batch size' do
      create(:certificate, state: 'installed', last_renewed_at: 40.days.ago)
      create(:certificate, state: 'installed', last_renewed_at: 50.days.ago)
      CertWatch.config.renewal_interval = 1.month
      CertWatch.config.renewal_batch_size = 1

      RenewExpiringCertificatesJob.perform_now

      expect(Certificate.where(state: 'renewing').count).to eq(1)
    end
  end
end
