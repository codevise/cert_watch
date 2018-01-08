
require 'support/helpers/doubles'

FactoryGirl.define do
  factory(:certificate, class: CertWatch::Certificate) do
    domain 'some.example.com'
    state 'not_installed'

    trait :complete do
      public_key Doubles::PUBLIC_KEY
      private_key Doubles::PRIVATE_KEY
      chain Doubles::CHAIN
    end

    trait :auto_renewable do
      provider 'certbot'
    end

    trait :custom do
      provider 'custom'
    end
  end
end
