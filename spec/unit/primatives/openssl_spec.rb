require 'spec_helper'

describe Yasst::Primatives::OpenSSL do
  let(:prim_class) do
    Class.new do
      include Yasst::Primatives::OpenSSL
      public :p_salt, :p_cipher, :p_pbkdf2_key, :p_encrypt_string,
             :p_pack_string, :p_decrypt_string, :p_unpack_string
      def initialize
        super
      end
    end
  end

  # instance of primatives class
  let(:prim_class_inst) { prim_class.new }
  # common defaults - reuse salt and other parts just for testing, need to test
  # 'real' encrypt/decrypt methods uses unique key, salt & iv for every action
  let(:secret_data) { 'top secret lolz' }
  let(:algorithm) { 'AES-256-CBC' }
  let(:passphrase) { 'a passphrase' }
  let(:salt_bytes) { 8 }
  # iv length for AES-256
  let(:iv_length) { 16 }
  let(:salt) { prim_class_inst.p_salt(salt_bytes) }
  let(:iterations) { 50_000 }
  let(:key_length) { 32 }

  describe 'p_salt' do
    it 'should raise an error if salt_bytes is not given' do
      expect { prim_class_inst.p_salt }.to raise_error(ArgumentError)
    end

    it 'should return a 8 byte salt as a String' do
      salt_str = prim_class_inst.p_salt(8)
      expect(salt_str).to be_a(String)
      expect(salt_str.size).to eq(8)
    end
  end

  describe 'p_cipher' do
    let(:cipher) { prim_class_inst.p_cipher('AES-128-CBC') }

    it 'should raise an error if algorithm is not given' do
      expect { prim_class_inst.p_cipher }.to raise_error(ArgumentError)
    end
    it 'should be an OpenSSL::Cipher object' do
      expect(cipher).to be_a(OpenSSL::Cipher)
    end
    it 'should have a block size of 16' do
      expect(cipher.block_size).to eq(16)
    end
    it 'should be using the configured algorithm (AES-128-CBC)' do
      expect(cipher.name).to eq('AES-128-CBC')
    end
  end

  describe 'p_pbkdf2_key' do
    it 'should return a PBKDF2 key as a 32 byte string' do
      key = prim_class_inst.p_pbkdf2_key(
        passphrase, salt,
        iterations, key_length)
      expect(key).to be_a(String)
      expect(key.length).to eq(32)
    end
  end

  describe 'p_encrypt_string' do
    let(:key) do
      prim_class_inst.p_pbkdf2_key(passphrase, salt, iterations, key_length)
    end
    it 'should return an 16 byte IV and a base-64 encoded string' do
      iv, ciphertext = prim_class_inst.p_encrypt_string(
        secret_data, key, algorithm
      )
      expect(iv).to be_a(String)
      expect(iv.length).to eq(16)
      expect(ciphertext).to be_a(String)
    end
  end

  describe 'p_pack_string' do
    let(:key) do
      prim_class_inst.p_pbkdf2_key(passphrase, salt, iterations, key_length)
    end
    let(:cipher) { prim_class_inst.p_cipher('AES-256-CBC') }
    it 'should pack the data into a 108 byte string' do
      t_iv, t_ciphertext = prim_class_inst.p_encrypt_string(
        secret_data, key, algorithm
      )
      expect(
        prim_class_inst.p_pack_string(t_iv, salt, t_ciphertext)
      ).to be_a(String)
      expect(
        prim_class_inst.p_pack_string(t_iv, salt, t_ciphertext).size)
        .to eq(108)
    end
  end

  describe 'p_unpack_string' do
    let(:key) do
      prim_class_inst.p_pbkdf2_key(passphrase, salt, iterations, key_length)
    end
    it 'should unpack the data' do
      # generate iv and ciphertext
      iv, ciphertext = prim_class_inst.p_encrypt_string(
        secret_data, key, algorithm
      )
      # pack it
      packed = prim_class_inst.p_pack_string(iv, salt, ciphertext)
      t_salt, t_iv, t_ciphertext = prim_class_inst.p_unpack_string(
        packed, key_length, iv_length, salt_bytes
      )
      expect(t_salt).to be_a(String)
      expect(t_salt.size).to eq(salt_bytes)
      expect(t_salt).to eq(salt)
      expect(t_iv).to be_a(String)
      expect([24, 32]).to include(t_iv.size)
      expect(t_ciphertext).to be_a(String)
    end
  end

  describe 'p_decrypt_string' do
    # separate encrypt and decrypt cipher objects
    let(:key) do
      prim_class_inst.p_pbkdf2_key(passphrase, salt, iterations, key_length)
    end
    it 'should decrypt the ciphertext' do
      # generate iv and ciphertext using generic key
      t_iv, t_ciphertext = prim_class_inst.p_encrypt_string(
        secret_data, key, algorithm
      )
      # create a new key
      t_key = prim_class_inst.p_pbkdf2_key(
        passphrase, salt,
        iterations, key_length
      )
      # decrypt the data
      expect(
        prim_class_inst.p_decrypt_string(
          t_ciphertext, t_key, t_iv, algorithm
        )).to eq(secret_data)
    end
  end
end
