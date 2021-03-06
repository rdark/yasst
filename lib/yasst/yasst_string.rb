##
# Decorator pattern for String
#
# TODO: only way to tell an already encrypted new YasstString object that it is
# encrypted is by telling it so at initialization time. Is there a more elegant
# way of doing this without imposing overhead?
class YasstString < String
  def initialize(str = '', encrypted = false)
    super(str)
    @encrypted = encrypted
  end

  ##
  # Encrypt self using a Yasst::Provider
  def encrypt(provider)
    raise Yasst::Error::AlreadyEncrypted,
          'String is already encrypted' if encrypted?
    @encrypted = true
    replace(provider.encrypt(to_s))
  end

  ##
  # Whether or not the encrypt method has been called
  def encrypted?
    @encrypted ||= false
  end

  ##
  # Decrypt self using a Yasst::Provider
  def decrypt(provider)
    raise Yasst::Error::AlreadyDecrypted,
          'File is already decrypted' unless encrypted?
    @encrypted = false
    replace(provider.decrypt(to_s))
  end
end
