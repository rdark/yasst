require 'base64'
require 'openssl'
require 'digest/sha2'

module Yasst
  module Primatives
    # OpenSSL primatives mixin
    module OpenSSL
      private

      # Generate a random salt
      # ===== Parameters
      # - +salt_bytes+
      #   Size of the salt to be generated in bytes
      def p_salt(salt_bytes)
        ::OpenSSL::Random.random_bytes(salt_bytes)
      end

      # Return a cipher object
      #
      # ===== Parameters
      # - +algorithm+
      #   The algorithm to be used for the cipher (E.G 'AES-256-CBC')
      def p_cipher(algorithm)
        ::OpenSSL::Cipher.new(algorithm)
      end

      # Return a PBKDF2 HMAC SHA1 key
      #
      # ===== Parameters
      # - +passphrase+
      #   The passphrase to be used for generation of the key
      # - +salt+
      #   A random salt to be used for generation of the key
      # - +iterations+
      #   How many rounds of SHA1 hashing to use (recommend minimum 20k)
      # - +key_length+
      #   How long the key should be (should match the requirements of your
      #   cipher algorithm)
      def p_pbkdf2_key(passphrase, salt, iterations, key_length)
        ::OpenSSL::PKCS5.pbkdf2_hmac_sha1(
          passphrase,
          salt,
          iterations,
          key_length
        )
      end

      # Encrypt a string
      #
      # ===== Parameters
      # - +string+
      #   Data to be encrypted, presented as a string
      # - +key+
      #   Encryption key to be used
      # - +algorithm+
      #   Algorithm to use for the cipher
      #
      # ===== Returns
      # - +iv+
      #   Initialisation vector used for the encryption
      # - +ciphertext+
      #   The ciphertext
      def p_encrypt_string(string, key, algorithm)
        cipher = p_cipher(algorithm)
        cipher.encrypt
        cipher.key = key
        # random_iv sets + returns simultaneously, grab output for prepending
        iv = cipher.random_iv
        ciphertext = cipher.update(Base64.urlsafe_encode64(string))
        # not required for streaming ciphers but compatible/recommended anyway
        ciphertext << cipher.final
        [iv, ciphertext]
      end

      # Decrypt ciphertext string
      #
      # ===== Parameters
      # - +ciphertext+
      #   Raw ciphertext as a string
      # - +key+
      #   Key that will be used to decrypt the ciphertext
      # - +iv+
      #   Initialisation Vector for the ciphertext
      # - +algorithm+
      #   Algorithm to use for the cipher
      def p_decrypt_string(ciphertext, key, iv, algorithm)
        cipher = p_cipher(algorithm)
        cipher.key = key
        cipher.iv = iv
        cipher.decrypt
        # decrypt ciphertext
        encoded_plain = cipher.update(ciphertext)
        encoded_plain << cipher.final
        # return the decoded plaintext
        Base64.urlsafe_decode64(encoded_plain)
      end

      # Pack a string ready for storing
      #
      # ===== Parameters
      # - +iv+
      #   The IV used during encryption of the ciphertext
      # - +salt+
      #   The salt used for generation of the encryption key
      def p_pack_string(iv, salt, ciphertext)
        output = ciphertext
        output.prepend(iv)
        output.prepend(salt)
        Base64.urlsafe_encode64(output)
      end

      # Unpack a string ready for decryption
      #
      # ===== Parameters
      # - +string+
      #   Base64 encoded string containing the ciphertext with prepended salt
      #   and IV
      # - +key_length+
      #   The size (in bytes) of the encryption key used to encrypt the data
      # - +iv_length+
      #   The size (in bytes) of the IV used to encrypt the data
      # - +salt_bytes+
      #   The size (in bytes) of the salt used to generate the encryption key
      #
      # ===== Returns
      # - +salt+
      #   The salt that was prepended to the string
      # - +iv+
      #   The IV that was prepended to the string
      # - +ciphertext+
      #   The ciphertext (which should still be base64 encoded)
      def p_unpack_string(string, key_length, iv_length, salt_bytes)
        # remove base64 wrapping
        string = Base64.urlsafe_decode64(string)
        # pull out prepended salt and build the key using it
        salt = string.byteslice(0..(salt_bytes - 1))
        # pull out prepended IV
        iv = string.byteslice(salt_bytes..(key_length - 1))
        # pull out remaining data, which is the ciphertext
        ciphertext = string.byteslice((salt_bytes + iv_length)..string.bytesize)
        [salt, iv, ciphertext]
      end
    end
  end
end
