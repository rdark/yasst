require 'yasst/primatives/openssl/metadata'

module Yasst
  module Profiles
    ##
    # OpenSSL Profile
    class OpenSSL < Yasst::Profile
      attr_reader :algorithm, :key_gen_method, :pbkdf2_iterations,
                  :key_len, :iv_len
      attr_accessor :salt_bytes

      DEFAULT_SALT_BYTES = 8
      DEFAULT_KEY_GEN_METHOD = :pbkdf2
      DEFAULT_PBKDF2_ITERATIONS = 50_000
      DEFAULT_ALGORITHM = 'AES-256-CBC'.freeze
      SUPPORTED_KEY_GEN_METHODS = [:pbkdf2].freeze

      include Yasst::Primatives::OpenSSL::Metadata

      def initialize(**args)
        args[:algorithm].nil? && (self.algorithm = DEFAULT_ALGORITHM) ||
          (self.algorithm = args[:algorithm])
        args[:salt_bytes].nil? && (@salt_bytes = DEFAULT_SALT_BYTES) ||
          (self.salt_bytes = args[:salt_bytes])
        args[:key_gen_method].nil? &&
          (self.key_gen_method = DEFAULT_KEY_GEN_METHOD) ||
          (self.key_gen_method = args[:key_gen_method])
        args[:pbkdf2_iterations].nil? &&
          (self.pbkdf2_iterations = DEFAULT_PBKDF2_ITERATIONS) ||
          (self.pbkdf2_iterations = args[:pbkdf2_iterations])
      end

      ##
      # files matching this are deemed to be already encrypted by default
      # TODO: auto file extension based on the algorithm in use
      def file_extension
        'aes'
      end

      # setter method for algorithm
      def algorithm=(alg)
        valgs = Yasst::Primatives::OpenSSL::Metadata.list_ciphers
        unless valgs.include? alg
          raise Yasst::Error::InvalidCryptoAlgorithm,
                "Invalid algorithm. Valid algorithms are #{valgs.join(', ')}"
        end
        @key_len = Yasst::Primatives::OpenSSL::Metadata.key_len_for(alg)
        @iv_len = Yasst::Primatives::OpenSSL::Metadata.iv_len_for(alg)
        @algorithm = alg
      end

      def key_gen_method=(method)
        if SUPPORTED_KEY_GEN_METHODS.include? method
          @key_gen_method = method
        else
          raise NotImplementedError,
                'Invalid or not-yet-implemented key generation method. Valid ' \
                "methods are #{SUPPORTED_KEY_GEN_METHODS.join(', ')}"
        end
      end

      # set number of pbkdf2_iterations. Only set if key_gen_method is :pbkdf2
      def pbkdf2_iterations=(iterations)
        @key_gen_method == :pbkdf2 && (@pbkdf2_iterations = iterations) ||
          (@pbkdf2_iterations = nil)
      end
    end
  end
end
