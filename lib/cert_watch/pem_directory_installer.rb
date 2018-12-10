module CertWatch
  class PemDirectoryInstaller < Installer
    def initialize(options)
      @pem_directory = options.fetch(:pem_directory)
      @provider_directory_mapping =
        options
        .fetch(:provider_directory_mapping, {})
        .with_indifferent_access
      @reload_command = options[:reload_command]
    end

    def install(provider:, domain:, public_key:, private_key:, chain:)
      if Rails.env.development?
        Rails.logger.info("[CertWatch] Skipping certificate install for #{domain} in development.")
        return
      end

      Sanitize.check_domain!(domain)

      write_pem_file(provider, domain, join([public_key, chain, private_key]))
      perform_reload_command
    end

    private

    def join(parts)
      parts.map(&:strip).join("\n") + "\n"
    end

    def write_pem_file(provider, domain, contents)
      sudo("echo -n '#{contents}' > '#{pem_file(provider, domain)}'")
    end

    def pem_file(provider, domain)
      File.join(*[@pem_directory,
                  @provider_directory_mapping[provider],
                  "#{domain}.pem"].compact)
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
