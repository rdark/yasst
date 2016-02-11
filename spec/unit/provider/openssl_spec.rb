require 'spec_helper'

describe Yasst::Provider::OpenSSL do
  let(:valid_passphrase) { 'a s3mi str0ng pa5r5phrase' }
  it 'should raise InvalidPassPhrase with arguments' do
    expect { Yasst::Provider::OpenSSL.new }
      .to raise_error(Yasst::Error::InvalidPassPhrase)
  end
  it 'should initialize successfully with a valid passphrase' do
    expect { Yasst::Provider::OpenSSL.new(passphrase: valid_passphrase) }
      .to_not raise_error
  end

  describe 'profile configuration' do
    before(:all) do
      @default_profile = Yasst::Profiles::OpenSSL.new
    end
    before(:each) do
      # reset fresh crypto object with a default profile
      @fresh_object = Yasst::Provider::OpenSSL.new(
        profile: @default_profile,
        passphrase: valid_passphrase
      )
    end

    it 'should have a profile' do
      expect(@fresh_object.profile).to_not be(nil)
    end

    it 'should setup a default profile when not given one' do
      test_object = Yasst::Provider::OpenSSL.new(passphrase: valid_passphrase)
      expect(test_object.profile).to be_a_kind_of(Yasst::Profile)
      expect(test_object.profile).to be_a(Yasst::Profiles::OpenSSL)
    end

    it 'should be able to fetch default algorithm from the profile' do
      expect(@fresh_object.profile.algorithm).to eq('AES-256-CBC')
    end

    it 'should fetch default key generation method from the profile ' do
      expect(@fresh_object.profile.key_gen_method).to eq(:pbkdf2)
    end
  end

  describe 'passphrase config' do
    let(:default_provider) do
      Yasst::Provider::OpenSSL.new(
        passphrase: valid_passphrase
      )
    end
    it 'should require a passphrase' do
      expect(default_provider.passphrase_required?).to eq(true)
    end
    it 'should not allow me to set an invalid passphrase after a good one' do
      expect do
        t_provider = Yasst::Provider::OpenSSL.new(passphrase: valid_passphrase)
        t_provider.passphrase = 'a'
      end.to raise_error(Yasst::Error::InvalidPassPhrase)
    end
  end

  describe 'encrypt' do
    let(:test_string) { 'a test string' }
    before(:all) do
      @default_profile = Yasst::Profiles::OpenSSL.new
    end
    before(:each) do
      # reset fresh crypto object with a default profile
      @fresh_object = Yasst::Provider::OpenSSL.new(
        profile: @default_profile,
        passphrase: valid_passphrase
      )
    end
    it 'should raise an ArgumentError with no arguments' do
      expect { @fresh_object.encrypt }.to raise_error(ArgumentError)
    end

    it 'should return an encrypted YasstString which is a kind of string' do
      expect(@fresh_object.encrypt(test_string)).to be_a(String)
    end
  end

  describe 'decrypt' do
    let(:test_string) { 'a test string' }
    # base64 string encrypted with default test passphrase
    let(:test_string_enc) do
      'rISOfO9lFyXLa1kEqofzzUuQt_lcc0-elYfADfORGswbnpQjj9-4Jn_' \
      'S2P8pubktY0r_aTvN4kM='
    end
    before(:all) do
      @default_profile = Yasst::Profiles::OpenSSL.new
    end
    before(:each) do
      # reset fresh crypto object with a default profile
      @fresh_object = Yasst::Provider::OpenSSL.new(
        profile: @default_profile,
        passphrase: valid_passphrase
      )
    end
    it 'should raise an ArgumentError with no arguments' do
      expect { @fresh_object.decrypt }.to raise_error(ArgumentError)
    end

    it 'should return the decrypted String which is a kind of string' do
      decrypted = @fresh_object.decrypt(test_string_enc)
      expect(decrypted).to be_a(String)
      expect(decrypted).to eq(test_string)
    end
  end
end
