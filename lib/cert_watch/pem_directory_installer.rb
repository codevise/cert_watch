module CertWatch
  class PemDirectoryInstaller
    def initialize(options)
      @pem_directory = options.fetch(:pem_directory)
      @input_directory = options.fetch(:input_directory)
    end

    def install(domain)
    end
  end
end
