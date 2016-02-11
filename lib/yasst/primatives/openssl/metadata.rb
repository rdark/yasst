require 'openssl'

module Yasst
  module Primatives
    module OpenSSL
      ##
      # Methods for returning various bits of information
      module Metadata
        ##
        # List available ciphers
        def self.list_ciphers
          ::OpenSSL::Cipher.ciphers
        end

        # Return the key length for a given cipher algorithm
        def self.key_len_for(alg)
          cipher = ::OpenSSL::Cipher.new(alg)
          cipher.key_len
        end

        # Return the key length for a given cipher algorithm
        def self.iv_len_for(alg)
          cipher = ::OpenSSL::Cipher.new(alg)
          cipher.iv_len
        end
      end
    end
  end
end
