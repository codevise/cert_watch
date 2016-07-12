module CertWatch
  class CertbotClient < Client
    def initialize(options)
      @executable = options.fetch(:executable)
      @port = options.fetch(:port)
    end

    def renew(domain)
    end
  end
end
