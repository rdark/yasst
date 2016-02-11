require 'yasst/primatives/openssl'

module Yasst
  class Provider
    ##
    # OpenSSL provider
    # ===== Parameters
    # - *profile*
    # ===== Required Parameters
    # - *passphrase*
    class OpenSSL < Yasst::Provider
      include Yasst::Primatives::OpenSSL

      attr_reader :profile

      ##
      # initialize hook for superclass
      def post_initialize(**args)
        args[:profile].nil? && (@profile = Yasst::Profiles::OpenSSL.new) ||
          (@profile = args[:profile])
        validate_passphrase(@passphrase)
      end

      ##
      # Whether or not a passphrase is required for this provider
      def passphrase_required?
        true
      end

      ##
      # Encrypt a string using a unique salt + key for every encrypt action,
      # and then package it up in a usable base64'd string with iv + salt
      # prepended
      #
      # ===== Parameters
      # - +string+
      #   A string to encrypt
      # ===== Returns
      # - String
      def encrypt(string)
        e_salt = salt
        e_key = key(e_salt)
        e_iv, ciphertext = p_encrypt_string(string, e_key, profile.algorithm)
        p_pack_string(e_iv, e_salt, ciphertext)
      end

      ##
      # De-encode, unpack and decrypt a string
      #
      # ===== Parameters
      # - +string+
      #   A base64-encoded string to decrypt. Must be in the same format as the
      #   encrypt method produces
      # ===== Returns
      def decrypt(string)
        d_salt, d_iv, ciphertext = p_unpack_string(
          string,
          profile.key_len,
          profile.iv_len,
          profile.salt_bytes
        )
        p_decrypt_string(ciphertext, key(d_salt), d_iv, profile.algorithm)
      end

      private

      ##
      # Returns a brand new salt
      def salt
        p_salt(profile.salt_bytes)
      end

      ##
      # Returns a new key for the configured key gen method.
      # Called with no parameters, a fresh salt will be used
      # ===== Parameters
      # - +salt+
      #   Optional salt value to use when generating the key
      def key(salt = nil)
        salt.nil? && salt = new_salt
        # Profile should raise NotImplementedErrror if unsupported key
        # generation method is used
        if profile.key_gen_method == :pbkdf2
          return p_pbkdf2_key(@passphrase, salt,
                              profile.pbkdf2_iterations, profile.key_len)
        end
      end
    end
  end
end
