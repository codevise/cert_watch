module CertWatch
  class CertbotClient < Client
    def initialize(options)
      @executable = options.fetch(:executable)
      @port = options.fetch(:port)
      @output_directory = options.fetch(:output_directory)
      @shell = options.fetch(:shell, Shell)
    end

    def renew(domain)
      if Rails.env.development?
        Rails.logger.info("[CertWatch] Skipping certificate renewal for #{domain} in development.")
        return
      end

      @shell.sudo(renew_command(domain))

      read_outputs(domain)
    rescue Shell::CommandFailed => e
      fail(RenewError, e.message)
    end

    def read_outputs(domain)
      {
        public_key: read_output(domain, 'cert.pem'),
        private_key: read_output(domain, 'privkey.pem'),
        chain: read_output(domain, 'chain.pem')
      }
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

    def read_output(domain, file_name)
      @shell.sudo_read(File.join(@output_directory, domain, file_name))
    end
  end
end
