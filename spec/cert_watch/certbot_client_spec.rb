require 'rails_helper'

module CertWatch
  RSpec.describe CertbotClient do
    let(:client) do
      CertbotClient.new(executable: '/usr/bin/certbot',
                        port: 99)
    end

    it 'invokes given executable' do
      command = client.renew_command('some.example.com')

      expect(command).to include('/usr/bin/certbot')
    end

    it 'passes given port' do
      command = client.renew_command('some.example.com')

      expect(command).to include('--http-01-port 99')
    end

    it 'passes domain' do
      command = client.renew_command('some.example.com')

      expect(command).to include('-d some.example.com')
    end

    it 'fails if domain contains forbidden characters' do
      expect do
        client.renew_command('some.example.com;" rm *')
      end.to raise_error(Sanitize::ForbiddenCharacters)
    end

    it 'passes --renew-by-default flag' do
      command = client.renew_command('some.example.com')

      expect(command).to include('--renew-by-default')
    end
  end
end
