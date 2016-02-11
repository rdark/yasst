require 'spec_helper'

describe Yasst::Profiles::OpenSSL do
  let(:default_algo) { 'AES-256-CBC' }
  let(:default_key_gen_method) { :pbkdf2 }
  let(:default_salt_bytes) { 8 }
  let(:default_pbkdf2_iterations) { 50_000 }

  it 'should initialize successfully with no arguments' do
    expect { Yasst::Profiles::OpenSSL.new }.to_not raise_error
  end

  it 'should be a Yasst::Profile' do
    profile = Yasst::Profiles::OpenSSL.new
    expect(profile).to be_a_kind_of(Yasst::Profile)
  end

  describe 'algorithm configuration' do
    before(:each) do
      @fresh_object = Yasst::Profiles::OpenSSL.new
    end
    it 'should set a default algorithm if not provided' do
      expect(@fresh_object.algorithm).to eq(default_algo)
    end

    it 'should allow me to set any valid OpenSSL algorithm' do
      expect { Yasst::Profiles::OpenSSL.new(algorithm: 'RC2') }
        .to_not raise_error
      profile = Yasst::Profiles::OpenSSL.new(algorithm: 'RC2')
      expect(profile.algorithm).to eq('RC2')
    end

    it 'should automatically set the key length' do
      t_profile = Yasst::Profiles::OpenSSL.new(algorithm: 'RC2')
      expect(t_profile.key_len).to eq(16)
      t_profile.algorithm = 'RC2-40-CBC'
      expect(t_profile.key_len).to eq(5)
    end

    it 'should automatically set the iv length' do
      t_profile = Yasst::Profiles::OpenSSL.new(algorithm: 'RC2')
      expect(t_profile.key_len).to eq(16)
      t_profile.algorithm = 'RC2-40-CBC'
      expect(t_profile.key_len).to eq(5)
    end

    it 'should raise InvalidCryptoAlgorithm when given an invalid algorithm' do
      expect { Yasst::Profiles::OpenSSL.new(algorithm: 'caesar') }
        .to raise_error(Yasst::Error::InvalidCryptoAlgorithm)
    end
  end

  describe 'key generation configuration' do
    before(:each) do
      @fresh_object = Yasst::Profiles::OpenSSL.new
    end
    it 'should set a default key generation method if not provided' do
      expect(@fresh_object.key_gen_method).to eq(default_key_gen_method)
    end

    it 'should set default pbkdf2 iterations if not provided' do
      expect(@fresh_object.pbkdf2_iterations).to eq(default_pbkdf2_iterations)
    end

    it 'should only support the pbkdf2 key generation method so far' do
      expect { Yasst::Profiles::OpenSSL.new(key_gen_method: 'wind power') }
        .to raise_error(NotImplementedError)
    end
  end

  describe 'salt bytes configuration' do
    before(:each) do
      @fresh_object = Yasst::Profiles::OpenSSL.new
    end
    it 'should set a default salt bytes if not provided' do
      expect(@fresh_object.salt_bytes).to eq(default_salt_bytes)
    end
  end
end
