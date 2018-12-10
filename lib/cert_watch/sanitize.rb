module CertWatch
  module Sanitize
    extend self

    class ForbiddenCharacters < Error; end

    def check_domain!(name)
      if name =~ Certificate::FORBIDDEN_DOMAIN_CHARACTERS
        fail(ForbiddenCharacters, "Domain '#{name}' contains forbidden characters.")
      end
    end
  end
end
