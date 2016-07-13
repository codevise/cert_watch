require 'rails_helper'

module CertWatch
  RSpec.describe Sanitize do
    describe '.check_domain!' do
      it 'fails if string contains forbidden characters' do
        expect do
          Sanitize.check_domain!('some.12-; rm *"')
        end.to raise_error(Sanitize::ForbiddenCharacters)
      end

      it 'handles multi line strings' do
        expect do
          Sanitize.check_domain!("valid\n rm *")
        end.to raise_error(Sanitize::ForbiddenCharacters)
      end
    end
  end
end
