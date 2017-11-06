module CertWatch
  class Client
    def renew(_domain)
      fail(NotImplementedError)
    end

    def read_outputs(_domain)
      fail(NotImplementedError)
    end
  end
end
