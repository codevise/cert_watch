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

      write_pem_file(domain)
      perform_reload_command
    end

    private

    def write_pem_file(domain)
      sudo('Write', "cat #{input_files(domain)} > #{pem_file(domain)}")
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
      sudo('Reload', @reload_command)
    end

    def sudo(name, command)
      output, input = IO.pipe
      prefix = !Rails.env.test? ? 'sudo ' : ''

      result = system([prefix, command].join, [:out, :err] => input)
      input.close

      unless result
        fail(InstallError, "#{name} command failed with output:\n\n#{output.read}\n")
      end
    end
  end
end
