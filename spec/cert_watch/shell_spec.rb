require 'rails_helper'

module CertWatch
  RSpec.describe Shell, fixture_files: true do
    describe '.sudo' do
      it 'runs given command' do
        Shell.sudo('echo "test" > foo')

        expect(File.read('foo')).to eq("test\n")
      end

      it 'returns output as strigng' do
        Fixtures.file('foo', "CONTENTS\n")

        result = Shell.sudo('cat foo')

        expect(result).to eq("CONTENTS\n")
      end

      it 'raises CommandFailed with output if command fails' do
        expect do
          Shell.sudo('LANG=en touch not/there')
        end.to raise_error(Shell::CommandFailed, /cannot touch/)
      end
    end

    describe '.sudo_read' do
      it 'returns file content' do
        Fixtures.file('foo', "CONTENTS\n")

        result = Shell.sudo_read('foo')

        expect(result).to eq("CONTENTS\n")
      end

      it 'raises CommandFailed if file is missing' do
        expect do
          Shell.sudo_read('not/there')
        end.to raise_error(Shell::CommandFailed, /No such file/)
      end
    end
  end
end
