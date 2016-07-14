module CertWatch
  class PemDirectoryInstaller
    def initialize(options)
      @pem_directory = options.fetch(:pem_directory)
      @input_directory = options.fetch(:input_directory)
      @reload_command = options[:reload_command]
    end

    def install(domain)
      if Rails.env.development?
        Rails.logger.info("[CertWatch] Skipping certificate install for #{domain} in development.")
        return
      end

      Sanitize.check_domain!(domain)
      write_pem_file(domain)
      perform_reload_command
    end

    private

    def write_pem_file(domain)
      sudo("cat #{input_files(domain)} > #{pem_file(domain)}")
    end

    def input_files(domain)
      ['fullchain.pem', 'privkey.pem'].map do |file_name|
        File.join(@input_directory, domain, file_name)
      end.join(' ')
    end

    def pem_file(domain)
      File.join(@pem_directory, "#{domain}.pem")
    end

    def perform_reload_command
      return unless @reload_command
      sudo(@reload_command)
    end

    def sudo(command)
      Shell.sudo(command)
    rescue Shell::CommandFailed => e
      fail(InstallError, e.message)
    end
  end
end
