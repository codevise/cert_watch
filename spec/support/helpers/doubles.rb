module Doubles
  extend RSpec::Mocks::ExampleMethods
  extend self

  def client
    instance_double('CertWatch::Client').tap do |double|
      allow(double).to receive(:renew).and_return(:ok)
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
