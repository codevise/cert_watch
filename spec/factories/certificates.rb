FactoryGirl.define do
  factory(:certificate, class: CertWatch::Certificate) do
    domain 'some.example.com'
    state 'not_installed'
  end
end
