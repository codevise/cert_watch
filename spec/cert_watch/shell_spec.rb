require 'rails_helper'

module CertWatch
  RSpec.describe Shell, fixture_files: true do
    describe '.sudo' do
      it 'runs given command' do
        Shell.sudo('echo "test" > foo')

        expect(File.read('foo')).to eq("test\n")
      end

      it 'raises CommandFailed with output if command fails' do
        expect do
          Shell.sudo('LANG=en touch not/there')
        end.to raise_error(Shell::CommandFailed, /cannot touch/)
      end
    end
  end
end
