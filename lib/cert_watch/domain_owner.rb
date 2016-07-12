module CertWatch
  module DomainOwner
    extend ActiveSupport::Concern

    included do
      after_save do
        if cname_changed?
          Certificate.find_by(domain: cname_was).try(:abandon)
          Certificate.find_or_create_by(domain: cname).renew
        end
      end
    end
  end
end
