require 'rails_helper'

require 'support/helpers/doubles'
require 'support/helpers/inline_resque'

module CertWatch
  RSpec.describe Certificate, inline_resque: true do
    describe '.auto_renewable' do
      it 'includes auto renewable certificates' do
        certificate = create(:certificate, :auto_renewable)

        expect(Certificate.auto_renewable).to include(certificate)
      end

      it 'does not include custom certificates' do
        certificate = create(:certificate, :custom)

        expect(Certificate.auto_renewable).not_to include(certificate)
      end
    end

    describe '.custom' do
      it 'includes custom certificates' do
        certificate = create(:certificate, :custom)

        expect(Certificate.custom).to include(certificate)
      end

      it 'does not include auto renewable certificates' do
        certificate = create(:certificate, :auto_renewable)

        expect(Certificate.custom).not_to include(certificate)
      end
    end

    describe 'can_renew?' do
      it 'returns true for auto renewable certificate' do
        certificate = create(:certificate, :auto_renewable)

        expect(certificate.can_renew?).to eq(true)
      end

      it 'returns false for custom certificate' do
        certificate = create(:certificate, :custom)

        expect(certificate.can_renew?).to eq(false)
      end
    end

    describe 'can_install?' do
      it 'returns true for complete installed auto renewable certificate' do
        certificate = create(:certificate, :auto_renewable, :complete, state: 'installed')

        expect(certificate.can_install?).to eq(true)
      end

      it 'returns false for not_installed auto renewable certificate' do
        certificate = create(:certificate, :auto_renewable, state: 'not_installed')

        expect(certificate.can_install?).to eq(false)
      end

      it 'returns false for complete custom certificate' do
        certificate = create(:certificate, :custom, :complete)

        expect(certificate.can_install?).to eq(true)
      end

      it 'returns false for incomplete custom certificate' do
        certificate = create(:certificate, :custom)

        expect(certificate.can_install?).to eq(false)
      end
    end

    describe '#renew' do
      it 'makes client renew certificate for domain' do
        certificate = create(:certificate, domain: 'my.example.com')

        certificate.renew!

        expect(CertWatch.client).to have_received(:renew).with('my.example.com')
      end

      it 'installs certificate' do
        certificate = create(:certificate,
                             provider: 'certbot',
                             domain: 'my.example.com')

        certificate.renew!

        expect(CertWatch.installer).to have_received(:install)
          .with(domain: 'my.example.com',
                provider: 'certbot',
                public_key: Doubles::PUBLIC_KEY,
                private_key: Doubles::PRIVATE_KEY,
                chain: Doubles::CHAIN)
      end

      it 'sets state to installed' do
        certificate = create(:certificate, domain: 'my.example.com')

        certificate.renew!

        expect(certificate.reload.state).to eq('installed')
      end

      it 'stores keys' do
        certificate = create(:certificate,
                             domain: 'my.example.com')

        certificate.renew!

        expect(certificate.reload.public_key).to be_present
        expect(certificate.reload.private_key).to be_present
        expect(certificate.reload.chain).to be_present
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

    describe '#install' do
      it 'installs certificate' do
        certificate = create(:certificate,
                             :complete,
                             provider: 'custom',
                             domain: 'my.example.com')

        certificate.install!

        expect(CertWatch.installer).to have_received(:install)
          .with(domain: 'my.example.com',
                provider: 'custom',
                public_key: Doubles::PUBLIC_KEY,
                private_key: Doubles::PRIVATE_KEY,
                chain: Doubles::CHAIN)
      end

      it 'sets state to installed' do
        certificate = create(:certificate, :complete, domain: 'my.example.com')

        certificate.install!

        expect(certificate.reload.state).to eq('installed')
      end

      it 'updates last_installed_at attribute' do
        certificate = create(:certificate,
                             :complete,
                             domain: 'my.example.com',
                             last_installed_at: 1.month.ago)

        certificate.install!

        expect(certificate.reload.last_installed_at).to eq(Time.now)
      end

      context 'when install results in error' do
        before do
          CertWatch.installer = Doubles.failing_installer
        end

        it 'sets state to installing_failed' do
          certificate = create(:certificate, :complete, domain: 'my.example.com')

          certificate.install!

          expect(certificate.reload.state).to eq('installing_failed')
        end

        it 'updates last_install_failed_at attribute' do
          certificate = create(:certificate,
                               :complete,
                               domain: 'my.example.com',
                               last_install_failed_at: 1.month.ago)

          certificate.install!

          expect(certificate.reload.last_install_failed_at).to eq(Time.now)
        end
      end
    end
  end
end
