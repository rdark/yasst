require 'spec_helper'

describe YasstString do
  let(:valid_passphrase) { 'a s3mi str0ng pa5r5phrase' }

  it 'should be a kind of String' do
    expect(YasstString.new).to be_a_kind_of(String)
  end

  describe 'encrypt' do
    before(:each) do
      @fresh_ystring = YasstString.new('some text')
      @fresh_provider = Yasst::Provider::OpenSSL.new(
        passphrase: valid_passphrase
      )
    end

    it 'should raise ArgumentError with no arguments' do
      expect { @fresh_ystring.encrypt }.to raise_error(ArgumentError)
    end

    it 'should be an instance method' do
      expect { YasstString.encrypt(@fresh_provider) }
        .to raise_error(NoMethodError)
    end

    it 'should not let me encrypt an empty string' do
      test_ystring = YasstString.new
      expect { test_ystring.encrypt(@fresh_provider) }
        .to raise_error(ArgumentError)
    end

    it 'should let me encrypt a test string (should be a YasstString)' do
      expect(@fresh_ystring.encrypt(@fresh_provider)).to be_a(YasstString)
    end

    # did have a more complete regex in place here previously but it randomly
    # failed on approx 1/50 tests
    it 'should be base64 encoded' do
      expect(@fresh_ystring.encrypt(@fresh_provider))
        .to match(/^[A-Za-z0-9_=+.-]+$/)
    end

    it 'should be encrypted' do
      @fresh_ystring.encrypt(@fresh_provider)
      expect(@fresh_ystring.encrypted?).to eq(true)
    end

    it 'should not be able to be encrypted twice' do
      @fresh_ystring.encrypt(@fresh_provider)
      expect { @fresh_ystring.encrypt(@fresh_provider) }
        .to raise_error(Yasst::Error::AlreadyEncrypted)
    end
  end

  describe 'decrypt' do
    before(:each) do
      @fresh_ystring = YasstString.new('some text')
      @fresh_provider = Yasst::Provider::OpenSSL.new(
        passphrase: valid_passphrase
      )
      @fresh_crypted = @fresh_ystring.encrypt(@fresh_provider)
    end

    it 'should raise ArgumentError with no arguments' do
      expect { @fresh_ystring.decrypt }.to raise_error(ArgumentError)
    end

    it 'should be an instance method' do
      expect { YasstString.decrypt(@fresh_provider) }
        .to raise_error(NoMethodError)
    end

    it 'should be a YasstString' do
      expect(@fresh_crypted.decrypt(@fresh_provider)).to be_a(YasstString)
    end

    it 'should contain the expected content' do
      expect(@fresh_crypted.decrypt(@fresh_provider)).to eq(@fresh_ystring)
    end

    it 'should not be encrypted' do
      @fresh_crypted.decrypt(@fresh_provider)
      expect(@fresh_ystring.encrypted?).to eq(false)
    end

    it 'should not be able to be decrypted twice' do
      @fresh_crypted.decrypt(@fresh_provider)
      expect { @fresh_crypted.decrypt(@fresh_provider) }
        .to raise_error(Yasst::Error::AlreadyDecrypted)
    end

    context 'with an already encrypted string as a new object' do
      let(:test_string) { 'a test string' }
      before(:all) do
        # base64 string encrypted with default test passphrase
        @already_enc_string = YasstString.new(
          'rISOfO9lFyXLa1kEqofzzUuQt_lcc0-elYfADfORGswbnpQjj9-4Jn_' \
          'S2P8pubktY0r_aTvN4kM=',
          true
        )
      end

      it 'should be encrypted' do
        expect(@already_enc_string.encrypted?).to eq(true)
      end

      it 'should not let me tell it that it is not encrypted' do
        expect { @already_enc_string.encrypted = false }
          .to raise_error(NoMethodError)
        expect(@already_enc_string.encrypted?).to eq(true)
      end

      it 'should let me decrypt it' do
        expect(@already_enc_string.decrypt(@fresh_provider))
          .to eq(test_string)
      end
    end
  end
end
