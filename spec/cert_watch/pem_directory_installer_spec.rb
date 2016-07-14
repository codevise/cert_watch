require 'rails_helper'

module CertWatch
  RSpec.describe PemDirectoryInstaller, fixture_files: true do
    before do
      Fixtures.file('live/some.example.com/fullchain.pem', "FULL CHAIN\n")
      Fixtures.file('live/some.example.com/privkey.pem', "PRIVATE KEY\n")
      Fixtures.directory('ssl')
    end

    it 'concatenates full chain and private key files' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'ssl',
                                            reload_command: 'touch reload.txt')
      installer.install('some.example.com')

      expect(File.read('ssl/some.example.com.pem')).to eq("FULL CHAIN\nPRIVATE KEY\n")
    end

    it 'invokes reload command' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'ssl',
                                            reload_command: 'touch reload.txt')
      installer.install('some.example.com')

      expect(File.exist?('reload.txt')).to eq(true)
    end

    it 'fails with InstallError if reload command fails' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'ssl',
                                            reload_command: './not_there')
      expect do
        installer.install('some.example.com')
      end.to raise_error(InstallError)
    end

    it 'fails with InstallError if input files not found' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'ssl')
      expect do
        installer.install('not-there.example.com')
      end.to raise_error(InstallError)
    end

    it 'does not create output file if input files not found' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'ssl')

      begin
        installer.install('not-there.example.com')
      rescue InstallError
      end

      expect(File.exist?('ssl/not-there.example.com.pem')).to eq(false)
    end

    it 'fails with InstallError if output directory does not exist' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'not-there')
      expect do
        installer.install('some.example.com')
      end.to raise_error(InstallError)
    end

    it 'fails if domain contains forbidden characters' do
      installer = PemDirectoryInstaller.new(input_directory: 'live',
                                            pem_directory: 'ssl')

      expect do
        installer.install('some.*example ".com')
      end.to raise_error(Sanitize::ForbiddenCharacters)
    end
  end
end
