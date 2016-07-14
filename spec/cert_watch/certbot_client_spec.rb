require 'rails_helper'

module CertWatch
  RSpec.describe CertbotClient do
    let(:shell) do
      instance_double('Shell', sudo: nil)
    end

    let(:client) do
      CertbotClient.new(executable: '/usr/bin/certbot',
                        port: 99,
                        shell: shell)
    end

    it 'invokes given executable' do
      client.renew('some.example.com')

      expect(shell).to have_received(:sudo).with(a_string_including('/usr/bin/certbot'))
    end

    it 'passes given port' do
      client.renew('some.example.com')

      expect(shell).to have_received(:sudo).with(a_string_including('--http-01-port 99'))
    end

    it 'passes domain' do
      client.renew('some.example.com')

      expect(shell).to have_received(:sudo).with(a_string_including('-d some.example.com'))
    end

    it 'fails if domain contains forbidden characters' do
      expect do
        client.renew('some.example.com;" rm *')
      end.to raise_error(Sanitize::ForbiddenCharacters)
    end

    it 'passes --renew-by-default flag' do
      client.renew('some.example.com')

      expect(shell).to have_received(:sudo).with(a_string_including('--renew-by-default'))
    end

    it 'fails with RenewError if shell command fails' do
      allow(shell).to receive(:sudo).and_raise(Shell::CommandFailed)

      expect do
        client.renew('some.example.com')
      end.to raise_error(RenewError)
    end
  end
end
