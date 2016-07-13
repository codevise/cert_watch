module CertWatch
  class CertbotClient < Client
    def initialize(options)
      @executable = options.fetch(:executable)
      @port = options.fetch(:port)
    end

    def renew(domain)
      if Rails.env.development?
        Rails.logger.info("[CertWatch] Skipping certificate renewal for #{domain} in development.")
        return
      end

      system(renew_command(domain))
    end

    def renew_command(domain)
      Sanitize.check_domain!(domain)
      "sudo #{@executable} #{flags} certonly -d #{domain}"
    end

    private

    def flags
      '--agree-tos --renew-by-default ' \
      "--standalone --standalone-supported-challenges http-01 --http-01-port #{@port}"
    end
  end
end
