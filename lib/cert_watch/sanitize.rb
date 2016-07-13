module CertWatch
  module Sanitize
    extend self

    class ForbiddenCharacters < Error; end

    def check_domain!(name)
      if name =~ /[^0-9a-zA-Z.-]/
        fail(ForbiddenCharacters, "Domain '#{name}' contains forbidden characters.")
      end
    end
  end
end
