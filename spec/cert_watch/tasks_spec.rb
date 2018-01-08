require 'rails_helper'
require 'cert_watch/tasks'

require 'support/helpers/doubles'
require 'support/helpers/inline_resque'

Rake::Task.define_task(:environment)

RSpec.describe 'tasks', fixture_files: true, inline_resque: true do
  describe 'cert_watch:reinstall:all' do
    it 'reinstalls installed certificates' do
      create(:certificate, state: 'installed', domain: 'some.example.com')

      Rake.application['cert_watch:reinstall:all'].invoke

      expect(CertWatch.installer).to have_received(:install)
        .with(hash_including(domain: 'some.example.com'))
    end
  end

  describe 'cert_watch:import:certbot' do
    it 'imports installed auto renewable certificates' do
      certificate = create(:certificate, :auto_renewable, state: 'installed')

      Rake.application['cert_watch:import:certbot'].invoke
      certificate.reload

      expect(certificate.public_key).to be_present
      expect(certificate.private_key).to be_present
      expect(certificate.chain).to be_present
    end
  end
end
