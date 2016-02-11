require 'spec_helper'

describe Yasst::Provider do
  it 'should initialize successfully with no arguments' do
    expect { Yasst::Provider.new }.to_not raise_error
  end

  describe 'passphrase configuration' do
    let(:valid_passphrase) { 'a s3mi str0ng pa5r5phrase' }
    context 'without a passphrase' do
      let(:default_provider) do
        Yasst::Provider.new
      end
      before(:each) do
        # reset fresh provider object
        @fresh_provider = Yasst::Provider.new(provider: @default_profile)
      end
      it 'should not require a passphrase' do
        expect(default_provider.passphrase_required?).to eq(false)
      end
      it 'and that should be valid' do
        expect(default_provider.passphrase_valid?).to eq(true)
      end
      it 'should not have a passphrase' do
        expect(default_provider.passphrase).to eq(nil)
      end

      it 'should allow me to set a new passphrase' do
        expect(@fresh_provider.passphrase).to eq(nil)
        @fresh_provider.passphrase = valid_passphrase
        expect(@fresh_provider.passphrase).to eq(valid_passphrase)
      end
    end
    context 'with a invalid passphrase' do
      it 'should raise an InvalidPassPhrase' do
        expect { Yasst::Provider.new(passphrase: 'a') }
          .to raise_error(Yasst::Error::InvalidPassPhrase)
      end
    end
    context 'with a valid passphrase' do
      let(:default_provider) do
        Yasst::Provider.new(passphrase: valid_passphrase)
      end

      it 'should have a passphrase' do
        expect(default_provider.passphrase).to eq(valid_passphrase)
      end
    end
  end
end
