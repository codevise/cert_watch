require 'rails_helper'

module CertWatch
  RSpec.describe CertbotClient do
    let(:shell) do
      instance_double('Shell', sudo: nil)
    end

    before do
      allow(shell).to receive(:sudo_read)
        .with('out/some.example.com/cert.pem')
        .and_return("PUBLIC KEY\n")

      allow(shell).to receive(:sudo_read)
        .with('out/some.example.com/privkey.pem')
        .and_return("PRIVATE KEY\n")

      allow(shell).to receive(:sudo_read)
        .with('out/some.example.com/chain.pem')
        .and_return("CHAIN\n")
    end

    let(:client) do
      CertbotClient.new(executable: '/usr/bin/certbot',
                        port: 99,
                        output_directory: 'out',
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

    it 'returns hash with contents of pem files' do
      result = client.renew('some.example.com')

      expect(result).to eql(public_key: "PUBLIC KEY\n",
                            private_key: "PRIVATE KEY\n",
                            chain: "CHAIN\n")
    end
  end
end
