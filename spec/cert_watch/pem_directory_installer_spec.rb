require 'rails_helper'

module CertWatch
  RSpec.describe PemDirectoryInstaller, fixture_files: true do
    before do
      Fixtures.directory('ssl/letsencrypt')
    end

    it 'concatenates full chain and private key files' do
      installer = PemDirectoryInstaller.new(pem_directory: 'ssl',
                                            reload_command: 'touch reload.txt')
      installer.install(domain: 'some.example.com',
                        provider: 'custom',
                        public_key: "PUBLIC KEY\n",
                        chain: "CHAIN\n",
                        private_key: "PRIVATE KEY\n")

      expect(File.read('ssl/some.example.com.pem')).to eq("PUBLIC KEY\nCHAIN\nPRIVATE KEY\n")
    end

    it 'ensures new lines between keys' do
      installer = PemDirectoryInstaller.new(pem_directory: 'ssl',
                                            reload_command: 'touch reload.txt')
      installer.install(domain: 'some.example.com',
                        provider: 'custom',
                        public_key: 'PUBLIC KEY',
                        chain: 'CHAIN',
                        private_key: 'PRIVATE KEY')

      expect(File.read('ssl/some.example.com.pem')).to eq("PUBLIC KEY\nCHAIN\nPRIVATE KEY\n")
    end

    it 'supports writing into provider specific directories' do
      installer = PemDirectoryInstaller.new(pem_directory: 'ssl',
                                            provider_directory_mapping: {certbot: 'letsencrypt'},
                                            reload_command: 'touch reload.txt')
      installer.install(domain: 'some.example.com',
                        provider: 'certbot',
                        public_key: "PUBLIC KEY\n",
                        chain: "CHAIN\n",
                        private_key: "PRIVATE KEY\n")

      expect(File.read('ssl/letsencrypt/some.example.com.pem'))
        .to eq("PUBLIC KEY\nCHAIN\nPRIVATE KEY\n")
    end

    it 'invokes reload command' do
      installer = PemDirectoryInstaller.new(pem_directory: 'ssl',
                                            reload_command: 'touch reload.txt')
      installer.install(domain: 'some.example.com',
                        provider: 'custom',
                        public_key: "PUBLIC KEY\n",
                        chain: "CHAIN\n",
                        private_key: "PRIVATE KEY\n")

      expect(File.exist?('reload.txt')).to eq(true)
    end

    it 'fails with InstallError if reload command fails' do
      installer = PemDirectoryInstaller.new(pem_directory: 'ssl',
                                            reload_command: './not_there')
      expect do
        installer.install(domain: 'some.example.com',
                          provider: 'custom',
                          public_key: "PUBLIC KEY\n",
                          chain: "CHAIN\n",
                          private_key: "PRIVATE KEY\n")
      end.to raise_error(InstallError)
    end

    it 'fails with InstallError if output directory does not exist' do
      installer = PemDirectoryInstaller.new(pem_directory: 'not-there')
      expect do
        installer.install(domain: 'some.example.com',
                          provider: 'custom',
                          public_key: "PUBLIC KEY\n",
                          chain: "CHAIN\n",
                          private_key: "PRIVATE KEY\n")
      end.to raise_error(InstallError)
    end

    it 'fails if domain contains forbidden characters' do
      installer = PemDirectoryInstaller.new(pem_directory: 'ssl')

      expect do
        installer.install(domain: 'some.*example ".com',
                          provider: 'custom',
                          public_key: "PUBLIC KEY\n",
                          chain: "CHAIN\n",
                          private_key: "PRIVATE KEY\n")
      end.to raise_error(Sanitize::ForbiddenCharacters)
    end
  end
end
