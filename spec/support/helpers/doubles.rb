module Doubles
  extend RSpec::Mocks::ExampleMethods
  extend self

  PUBLIC_KEY = "PUBLIC KEY\n".freeze
  PRIVATE_KEY = "PRIVATE KEY\n".freeze
  CHAIN = "CHAIN\n".freeze

  def client
    instance_double('CertWatch::Client').tap do |double|
      allow(double).to receive(:renew).and_return(public_key: PUBLIC_KEY,
                                                  private_key: PRIVATE_KEY,
                                                  chain: CHAIN)

      allow(double).to receive(:read_outputs).and_return(public_key: PUBLIC_KEY,
                                                         private_key: PRIVATE_KEY,
                                                         chain: CHAIN)
    end
  end

  def failing_client
    instance_double('CertWatch::Client').tap do |double|
      allow(double).to receive(:renew).and_raise(CertWatch::RenewError)
    end
  end

  def installer
    instance_double('CertWatch::Installer').tap do |double|
      allow(double).to receive(:install).and_return(:ok)
    end
  end

  def failing_installer
    instance_double('CertWatch::Installer').tap do |double|
      allow(double).to receive(:install).and_raise(CertWatch::InstallError)
    end
  end
end
