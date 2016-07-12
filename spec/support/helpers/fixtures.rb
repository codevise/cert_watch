require 'fileutils'

module Fixtures
  extend self

  def directory(path)
    FileUtils.mkdir_p(path)
  end

  def file(path, contents = '')
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
    Pathname.new(path)
  end
end

RSpec.configure do |config|
  config.around(:example, fixture_files: true) do |example|
    Dir.mktmpdir('cert_watch_spec') do |dir|
      Dir.chdir(dir) do
        example.call
      end
    end
  end
end
