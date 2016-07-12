module CertWatch
  class Client
    def renew(_domain)
      fail(NotImplementedError)
    end
  end
end
