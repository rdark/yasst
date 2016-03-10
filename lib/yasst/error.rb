module Yasst
  # Error classes for Yasst
  class Error < StandardError
    attr_reader :error

    def initialize(error = nil)
      @error = error
    end

    class InvalidCryptoProvider < self; end
    class InvalidCryptoProfile < self; end
    class InvalidCryptoAlgorithm < self; end
    class InvalidPassPhrase < self; end
    class InvalidFileDestination < self; end
    class AlreadyEncrypted < self; end
    class AlreadyDecrypted < self; end
  end
end
