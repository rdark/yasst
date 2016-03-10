##
# Decorator pattern for File
#
# TODO: initialise with a provider?
# * file encrypt state should be detected when passed through YasstFile.new -
#   but need to add a provider to it for detection at init time
# * possible use of destructive/non-destructive methods for optionally writing
#   files
# * check file open modes for destructive actions (e.g NOCREAT or something)
# * use a module/mixin for functional stuff
# * method for shredding files
# * verify support for blocks
# * helper methods and have a block that you can throw to open?
#   (encrypt_and_shred, open_and_decrypt, read?)
class YasstFile < File
  attr_writer :encrypted

  # if a provider does not provide a file_extension method then this is the
  # default file extension that will be used
  DEFAULT_ENC_FILE_EXT = 'enc'.freeze
  CRYPTO_METHODS = [:in_memory].freeze

  ##
  # Encrypt self using a Yasst::Provider
  # Returns a string with the path name of the encrypted file
  def encrypt(method = :in_memory)
    raise Yasst::Error::AlreadyEncrypted,
          'File is already encrypted' if encrypted?
    raise Yasst::Error::InvalidFileDestination,
          'encrypt_to is not set' if encrypt_to.nil?
    encrypt_using(method)
    encrypt_to
  end

  ##
  # Decrypt self using a Yasst::Provider
  # Returns a string with the path name of the decrypted file
  def decrypt(method = :in_memory)
    raise Yasst::Error::AlreadyDecrypted,
          'File is not encrypted' unless encrypted?
    raise Yasst::Error::InvalidFileDestination,
          'decrypt_to is not set' if decrypt_to.nil?
    decrypt_using(method)
    decrypt_to
  end

  def encrypted?
    @encrypted ||= false
  end

  def encrypt_to
    @encrypt_to ||= default_encrypt_to
  end

  def decrypt_to
    @decrypt_to ||= default_decrypt_to
  end

  ##
  # Where to write the encrypted version of the file to
  def encrypt_to=(e_path)
    raise Yasst::Error::InvalidFileDestination,
          'cannot overwrite self' if e_path == path
    @encrypt_to = e_path
  end

  ##
  # Where to decrypt the file to
  def decrypt_to=(d_path)
    raise Yasst::Error::InvalidFileDestination,
          'cannot overwrite self' if d_path == path
    @decrypt_to = d_path
  end

  ##
  # Setter method for provider. Also sets @encrypted where the filename matches
  # the extension for the provider, unless it has previously been set
  def provider=(provider)
    @provider = provider
    @encrypted.nil? && (matches_provider_extension? && @encrypted = true)
  end

  ##
  # If a file matches the provider profiles file extension, it is deemed to be
  # encrypted by default
  # Where a provider does not support the file_extension method, the default
  # extension is used to match against.
  def matches_provider_extension?
    ext = DEFAULT_ENC_FILE_EXT
    (@provider.profile.respond_to? 'file_extension') &&
      ext = @provider.profile.file_extension
    path =~ /#{ext}$/
  end

  private

  ##
  # The default destination that the encrypted file will be written.
  # This is the same as the path (i.e the parent directory of the file), if the
  # file already has a matching extension, otherwise it is the path with the
  # extension postfixed
  def default_encrypt_to
    return nil if encrypted?
    return "#{path}.#{DEFAULT_ENC_FILE_EXT}" unless
      @provider.profile.respond_to? 'file_extension'
    return path if path =~ /#{@provider.profile.file_extension}$/
    "#{path}.#{@provider.profile.file_extension}"
  end

  ##
  # The default destination that the decrypted file will be written.
  # This is the same as the path (i.e the parent directory of the file), if the
  # file already has a matching extension, otherwise it is the path with
  # encryption provider extension removed
  def default_decrypt_to
    return nil unless encrypted?
    prov_ext = DEFAULT_ENC_FILE_EXT
    (@provider.profile.respond_to? 'file_extension') &&
      prov_ext = @provider.profile.file_extension
    path.sub(/\.#{prov_ext}$/, '')
  end

  ##
  # execute an encrypt method
  def encrypt_using(method)
    raise NotImplementedError unless
      CRYPTO_METHODS.include? method
    method == :in_memory && encrypt_in_memory
  end

  ##
  # execute a decrypt method
  def decrypt_using(method)
    raise NotImplementedError unless
      CRYPTO_METHODS.include? method
    method == :in_memory && decrypt_in_memory
  end

  ##
  # Implementation of encrypt that reads a whole file into memory as a
  # YasstString, encrypts it and then writes out to the chosen destination
  # ensures that self.close is called on completion (or failure)
  def encrypt_in_memory
    ystr = YasstString.new(read)
    ystr.encrypt(@provider)
    begin
      open(encrypt_to, 'w') do |f|
        f << ystr
      end
    ensure
      close
    end
  end

  ##
  # Implementation of decrypt that reads a whole file into memory as a
  # YasstString, decrypts it and then writes out to the chosen destination
  # ensures that self.close is called on completion (or failure)
  def decrypt_in_memory
    ystr = YasstString.new(read, true)
    ystr.decrypt(@provider)
    begin
      open(decrypt_to, 'w') do |f|
        f << ystr
      end
    ensure
      close
    end
  end
end
