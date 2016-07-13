module CertWatch
  module DomainOwner
    def self.define(options)
      attribute = options.fetch(:attribute).to_s

      Module.new do
        extend ActiveSupport::Concern

        included do
          after_save do
            if changed.include?(attribute)
              previous_value = changes[attribute].first
              new_value = self[attribute]

              Certificate.find_by(domain: previous_value).try(:abandon)
              Certificate.find_or_create_by(domain: new_value).renew if new_value.present?
            end
          end
        end
      end
    end
  end
end
