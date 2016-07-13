require 'rails_helper'

module CertWatch
  module Views
    RSpec.describe CertificateState, type: :view_component do
      context 'with string argument' do
        it 'renders status tag for matching certificate' do
          create(:certificate, state: 'installed', domain: 'my.example.com')

          render(:cert_watch_certificate_state, 'my.example.com')

          expect(rendered).to have_selector('.status_tag.installed')
        end

        it 'renders status tag if certificate is not found' do
          render(:cert_watch_certificate_state, 'not.there.com')

          expect(rendered).to have_selector('.status_tag.not_found')
        end
      end

      context 'with certificate argument' do
        it 'renders status tag for certificate' do
          certificate = create(:certificate, state: 'installed', domain: 'my.example.com')

          render(:cert_watch_certificate_state, certificate)

          expect(rendered).to have_selector('.status_tag.installed')
        end
      end
    end
  end
end
