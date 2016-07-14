module CertWatch
  class CertbotClient < Client
    def initialize(options)
      @executable = options.fetch(:executable)
      @port = options.fetch(:port)
      @shell = options.fetch(:shell, Shell)
    end

    def renew(domain)
      if Rails.env.development?
        Rails.logger.info("[CertWatch] Skipping certificate renewal for #{domain} in development.")
        return
      end

      @shell.sudo(renew_command(domain))
    rescue Shell::CommandFailed => e
      fail(RenewError, e.message)
    end

    private

    def renew_command(domain)
      Sanitize.check_domain!(domain)
      "#{@executable} certonly #{flags} -d #{domain}"
    end

    def flags
      '--agree-tos --renew-by-default ' \
      "--standalone --standalone-supported-challenges http-01 --http-01-port #{@port}"
    end
  end
end
