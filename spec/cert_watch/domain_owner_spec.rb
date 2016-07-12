require 'rails_helper'

require 'support/helpers/doubles'

module CertWatch
  RSpec.describe DomainOwner do
    let(:test_domain_owner_model) do
      Class.new(ActiveRecord::Base) do
        self.table_name = :test_domain_owner
        include DomainOwner
      end
    end

    it 'renews certificate on create' do
      test_domain_owner_model.create!(cname: 'new.example.com')

      certificate = Certificate.find_by_domain('new.example.com')

      expect(certificate).to be_present
      expect(certificate.state).to eq('renewing')
    end

    it 'renews certificate on update' do
      domain_owner = test_domain_owner_model.create!(cname: 'old.example.com')

      domain_owner.update!(cname: 'new.example.com')
      certificate = Certificate.find_by_domain('new.example.com')

      expect(certificate).to be_present
      expect(certificate.state).to eq('renewing')
    end

    it 'does not renew certificate when cname is unchanged' do
      domain_owner = test_domain_owner_model.create!(name: 'Old', cname: 'some.example.com')
      certificate = Certificate.find_by_domain!('some.example.com')
      certificate.update!(state: 'installed')

      domain_owner.update!(name: 'New')

      expect(certificate.reload.state).to eq('installed')
    end

    it 'abandons old certificate on update' do
      domain_owner = test_domain_owner_model.create!(cname: 'old.example.com')

      domain_owner.update!(cname: 'new.example.com')
      certificate = Certificate.find_by_domain('old.example.com')

      expect(certificate.state).to eq('abandoned')
    end
  end
end
