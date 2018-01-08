require 'rails_helper'

module Admin
  RSpec.describe CertificatesController, type: :controller do
    describe '#index' do
      render_views

      it 'renders table with certificate domains' do
        create(:certificate, :custom, domain: 'some-custom.example.com')
        create(:certificate, :auto_renewable)

        get(:index)

        expect(response.body).to have_selector('td a', text: 'some-custom.example.com')
      end
    end

    describe '#show' do
      render_views

      it 'displays renew button for auto renewable certificate' do
        certificate = create(:certificate, :auto_renewable)

        get(:show, id: certificate)

        expect(response.body).to have_selector('[data-rel=renew]')
      end

      it 'displays install button for complete certificate' do
        certificate = create(:certificate, :custom, :complete)

        get(:show, id: certificate)

        expect(response.body).to have_selector('[data-rel=install]')
      end
    end

    describe '#renew' do
      it 'renews certificate' do
        certificate = create(:certificate, :auto_renewable)

        post(:renew, id: certificate)

        expect(certificate.reload.state).to eq('renewing')
      end
    end

    describe '#install' do
      it 'installs certificate' do
        certificate = create(:certificate, :complete, :auto_renewable)

        post(:install, id: certificate)

        expect(certificate.reload.state).to eq('installing')
      end
    end

    describe '#create' do
      it 'creates custom certificate' do
        post(:create, certificate: {
               domain: 'test.example.com',
               public_key: 'PUBLIC',
               private_key: 'PRIVATE',
               chain: 'CHAIN'
             })

        expect(CertWatch::Certificate.custom.where(domain: 'test.example.com')).to exist
      end
    end
  end
end
