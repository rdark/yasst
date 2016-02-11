require 'spec_helper'
describe Yasst::Primatives::OpenSSL::Metadata do
  describe 'list_ciphers' do
    it 'should return a list of available ciphers' do
      expect(Yasst::Primatives::OpenSSL::Metadata.list_ciphers)
        .to be_a(Array)
      expect(Yasst::Primatives::OpenSSL::Metadata.list_ciphers)
        .to include('AES-256-CBC')
    end
    it 'should return the key length for a cipher' do
      expect(Yasst::Primatives::OpenSSL::Metadata.key_len_for('CAST'))
        .to be(16)
    end
    it 'should return the iv length for a cipher' do
      expect(Yasst::Primatives::OpenSSL::Metadata.iv_len_for('CAST'))
        .to be(8)
    end
  end
end
