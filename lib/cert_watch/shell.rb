module CertWatch
  module Shell
    extend self

    class CommandFailed < Error; end

    def sudo_read(file_name)
      sudo("cat #{file_name}")
    end

    def sudo(command)
      output, input = IO.pipe
      env = 'LANG=en '
      prefix = !Rails.env.test? ? 'sudo ' : ''
      full_command = [env, prefix, command].join

      result = system(full_command, [:out, :err] => input)
      input.close

      unless result
        fail(CommandFailed, "Command '#{full_command}' failed with output:\n\n#{output.read}\n")
      end

      output.read
    end
  end
end
