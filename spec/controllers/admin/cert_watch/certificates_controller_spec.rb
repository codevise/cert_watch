require 'rails_helper'

module Admin
  RSpec.describe CertWatchCertificatesController, type: :controller do
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
