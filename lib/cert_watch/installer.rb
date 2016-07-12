module CertWatch
  class PemDirectoryInstaller < Installer
    def install(_domain)
      fail(NotImplementedError)
    end
  end
end
