module CertWatch
  class Configuration
    # Maximum age of certificates before renewal.
    attr_accessor :renewal_interval

    # Number of expiring certificates to renew in one run of the
    # `RenewExpiringCertificatesJob`.
    attr_accessor :renewal_batch_size

    # File name of the certbot executable.
    attr_accessor :certbot_executable

    # Port for the standalone certbot HTTP server
    attr_accessor :certbot_port

    # Directory to output obtained certificates to
    attr_accessor :certbot_output_directory

    # Directory the web server reads pem files from
    attr_accessor :pem_directory

    # Command to make server reload pem files
    attr_accessor :server_reload_command

    def initialize
      @renewal_interval = 1.month
      @renewal_batch_size = 10

      @certbot_executable = '/usr/local/share/letsencrypt/bin/certbot'
      @certbot_port = 9999
      @certbot_output_directory = '/etc/letsencrypt/live'

      @pem_directory = '/etc/haproxy/ssl/'
      @server_reload_command = '/etc/init.d/haproxy reload'
    end
  end
end
