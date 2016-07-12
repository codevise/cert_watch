require 'rails_helper'

require 'support/helpers/doubles'
require 'support/helpers/inline_resque'

module CertWatch
  RSpec.describe Certificate, inline_resque: true do
    describe '#renew'do
      it 'makes client renew certificate for domain' do
        certificate = create(:certificate, domain: 'my.example.com')

        certificate.renew!

        expect(CertWatch.client).to have_received(:renew).with('my.example.com')
      end

      it 'installs certificate' do
        certificate = create(:certificate, domain: 'my.example.com')

        certificate.renew!

        expect(CertWatch.installer).to have_received(:install).with('my.example.com')
      end

      it 'sets state to installed' do
        certificate = create(:certificate, domain: 'my.example.com')

        certificate.renew!

        expect(certificate.reload.state).to eq('installed')
      end

      it 'updates last_renewed_at attribute' do
        certificate = create(:certificate,
                             domain: 'my.example.com',
                             last_renewed_at: 1.month.ago)

        certificate.renew!

        expect(certificate.reload.last_renewed_at).to eq(Time.now)
      end

      it 'updates last_installed_at attribute' do
        certificate = create(:certificate,
                             domain: 'my.example.com',
                             last_installed_at: 1.month.ago)

        certificate.renew!

        expect(certificate.reload.last_installed_at).to eq(Time.now)
      end

      context 'when renew results in error' do
        before do
          CertWatch.client = Doubles.failing_client
        end

        it 'sets state to renewing_failed' do
          certificate = create(:certificate, domain: 'my.example.com')

          certificate.renew!

          expect(certificate.reload.state).to eq('renewing_failed')
        end

        it 'updates last_renewal_failed_at attribute' do
          certificate = create(:certificate,
                               domain: 'my.example.com',
                               last_renewal_failed_at: 1.month.ago)

          certificate.renew!

          expect(certificate.reload.last_renewal_failed_at).to eq(Time.now)
        end
      end

      context 'when install results in error' do
        before do
          CertWatch.installer = Doubles.failing_installer
        end

        it 'sets state to installing_failed' do
          certificate = create(:certificate, domain: 'my.example.com')

          certificate.renew!

          expect(certificate.reload.state).to eq('installing_failed')
        end

        it 'updates last_install_failed_at attribute' do
          certificate = create(:certificate,
                               domain: 'my.example.com',
                               last_install_failed_at: 1.month.ago)

          certificate.renew!

          expect(certificate.reload.last_install_failed_at).to eq(Time.now)
        end
      end
    end
  end
end
