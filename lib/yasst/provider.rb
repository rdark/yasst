require 'yasst/provider/openssl'
module Yasst
  ##
  # Represents a Crypto Provider
  #
  # === Parameters
  # - *passphrase*
  #   The passphrase used for the provider instance. This is optional since
  #   some providers may not require a passphrase. Where passphrase is given,
  #   it must conform to minimum complexity requirements.
  class Provider
    attr_reader :passphrase

    PASSPHRASE_MIN_LENGTH = 8

    def initialize(**args)
      self.passphrase = args[:passphrase]
      post_initialize(args)
    end

    # post initialize hook for subclasses
    def post_initialize(**_args)
      nil
    end

    # setter method for passphrase
    def passphrase=(pass)
      validate_passphrase(pass) && @passphrase = pass
    end

    # validates a passphrase and raise on error
    def validate_passphrase(pass = @passphrase)
      unless passphrase_valid?(pass)
        fail Yasst::Error::InvalidPassPhrase,
             'Passphrase does not meet minimum requirements'
      end
      true
    end

    # Whether or not a passphrase is required for this provider instance
    # Should be overridden in the provider subclass if it requires a passphrase
    def passphrase_required?
      false
    end

    # Validate a passphrase
    # ===== Parameters
    # - +pass+
    #   String. The passphrase to be validated
    # ===== Returns
    # - true/false if the passphrase is valid or not
    def passphrase_valid?(pass = @passphrase)
      if pass.nil?
        return false if passphrase_required?
        return true
      end
      return false unless pass.length >= PASSPHRASE_MIN_LENGTH
      true
    end
  end
end
