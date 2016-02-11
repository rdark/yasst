require 'spec_helper'

describe Yasst::Error do
  it 'should allow me to raise an error without describing it' do
    expect { Yasst::Error.new }.to_not raise_error
  end

  it 'should allow me to set and return an error message at object creation ' \
     'time but not to change it afterwards' do
    error = Yasst::Error.new('test message')
    expect(error.error).to eq('test message')
    expect { error.error = 'a different message' }
      .to raise_error(NoMethodError)
  end

  describe 'InvalidCryptoProvider' do
    it 'should allow me to raise an InvalidCryptoProvider ' \
       'without describing it' do
      expect { Yasst::Error::InvalidCryptoProvider.new }
        .to_not raise_error
    end
  end
end
