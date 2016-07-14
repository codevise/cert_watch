module CertWatch
  module Shell
    extend self

    class CommandFailed < Error; end

    def sudo(command)
      output, input = IO.pipe
      prefix = !Rails.env.test? ? 'sudo ' : ''
      full_command = [prefix, command].join

      result = system(full_command, [:out, :err] => input)
      input.close

      unless result
        fail(CommandFailed, "Command '#{full_command}' failed with output:\n\n#{output.read}\n")
      end
    end
  end
end
