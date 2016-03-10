require 'spec_helper'

describe YasstFile do
  let(:plain_file_name) { 'plain_file.txt' }
  let(:plain_file_path) { "#{YasstTest::FIXTURES_DIR}/#{plain_file_name}" }
  let(:crypto_file_name) { 'plain_file.txt.aes' }
  let(:crypto_file_path) { "#{YasstTest::FIXTURES_DIR}/#{crypto_file_name}" }
  # where real encrypt output gets written to
  let(:crypto_file_out_path) do
    "#{YasstTest::FIXTURES_DIR}/tmp/#{crypto_file_name}"
  end
  let(:test_crypto_file_name) do
    "plain_file.txt.#{YasstTest::DEFAULT_ENC_FILE_EXT}"
  end
  let(:test_crypto_file_path) do
    "#{YasstTest::FIXTURES_DIR}/#{test_crypto_file_name}"
  end
  let(:valid_passphrase) { 'a s3mi str0ng pa5r5phrase' }
  let(:default_enc_file_ext) { YasstTest::DEFAULT_ENC_FILE_EXT }
  let(:test_provider) do
    double('Yasst::Provider', profile: {})
  end
  let(:openssl_provider) do
    Yasst::Provider::OpenSSL.new(passphrase: valid_passphrase)
  end

  it 'should be a kind of File' do
    expect(YasstFile.new(plain_file_path)).to be_a_kind_of(File)
  end

  describe 'encrypt_to' do
    let(:plain_file) { YasstFile.new(plain_file_path) }
    describe 'default behaviour' do
      context 'with the OpenSSL provider' do
        let(:crypto_file) { YasstFile.new(crypto_file_path) }
        context 'using a regular file extension' do
          it 'should be the file name, plus the extension of the provider' do
            plain_file.provider = openssl_provider
            expect(plain_file.encrypt_to).to eq(crypto_file_path)
          end
        end
        context 'with an already encrypted file extension' do
          it 'should be nil' do
            crypto_file.provider = openssl_provider
            expect(crypto_file.encrypt_to).to eq(nil)
          end
        end
      end
      context 'with a test provider' do
        let(:test_crypto_file) { YasstFile.new(test_crypto_file_path) }
        context 'using a regular file extension' do
          it 'should be the file name + default encrypted file extension' do
            plain_file.provider = test_provider
            expect(plain_file.encrypt_to).to eq(test_crypto_file_path)
          end
        end
        context 'with an already encrypted file extension' do
          it 'should be nil' do
            test_crypto_file.provider = test_provider
            expect(test_crypto_file.encrypt_to).to eq(nil)
          end
        end
      end
    end
  end

  describe 'decrypt_to' do
    let(:plain_file) { YasstFile.new(plain_file_path) }
    describe 'default behaviour' do
      context 'with the OpenSSL provider' do
        let(:crypto_file) { YasstFile.new(crypto_file_path) }
        context 'using a regular file extension' do
          it 'should be nil' do
            plain_file.provider = openssl_provider
            expect(plain_file.decrypt_to).to eq(nil)
          end
        end
        context 'with an already encrypted file extension' do
          it 'be the plain file name' do
            crypto_file.provider = openssl_provider
            expect(crypto_file.decrypt_to).to eq(plain_file_path)
          end
        end
      end
      context 'with a test provider' do
        let(:test_crypto_file) { YasstFile.new(test_crypto_file_path) }
        context 'using a regular file extension' do
          it 'should be nil' do
            plain_file.provider = test_provider
            expect(plain_file.decrypt_to).to eq(nil)
          end
        end
        context 'with an already encrypted file extension' do
          it 'be the plain file name' do
            test_crypto_file.provider = test_provider
            expect(test_crypto_file.decrypt_to).to eq(plain_file_path)
          end
        end
      end
    end
  end

  describe 'encrypt_to=' do
    context 'when not encrypted' do
      let(:plain_file) { YasstFile.new(plain_file_path) }
      it 'should not let me encrypt_to my own path' do
        expect { plain_file.encrypt_to = plain_file_path }
          .to raise_error(Yasst::Error::InvalidFileDestination)
      end
    end
  end

  describe 'decrypt_to=' do
    context 'when encrypted' do
      let(:crypto_file) { YasstFile.new(crypto_file_path) }
      it 'should not let me decrypt_to my own path' do
        expect { crypto_file.decrypt_to = crypto_file_path }
          .to raise_error(Yasst::Error::InvalidFileDestination)
      end
    end
  end

  describe 'file extension detection' do
    context 'with a file extension that does not match an crypto extensions' do
      context 'and I have not yet configured a provider' do
        before(:all) do
          @ysf = YasstFile.new("#{YasstTest::FIXTURES_DIR}/plain_file.txt")
        end

        it 'should not be encrypted' do
          expect(@ysf.encrypted?).to eq(false)
        end

        context 'when I have explicitly set encrypted to true' do
          it 'should be encrypted' do
            @ysf.encrypted = true
            expect(@ysf.encrypted?).to eq(true)
          end
        end

        context 'when I have explicitly set encrypted to false' do
          it 'should not be encrypted' do
            @ysf.encrypted = false
            expect(@ysf.encrypted?).to eq(false)
          end
        end

        context 'when I use the OpenSSL provider' do
          before(:all) do
            @ysf.encrypted = nil
            @ysf.provider = Yasst::Provider::OpenSSL.new(
              passphrase: 'a s3mi str0ng pa5r5phrase'
            )
          end

          it 'should not be encrypted' do
            expect(@ysf.encrypted?).to eq(false)
          end

          context 'when I have explicitly set encrypted to true' do
            it 'should be encrypted' do
              @ysf.encrypted = true
              expect(@ysf.encrypted?).to eq(true)
            end
          end

          context 'when I have explicitly set encrypted to false' do
            it 'should not be encrypted' do
              @ysf.encrypted = false
              expect(@ysf.encrypted?).to eq(false)
            end
          end
        end
      end
    end

    context 'with a file extension that matches a crypto extension' do
      context 'and I have not yet configured a provider' do
        before(:all) do
          @ysf = YasstFile.new("#{YasstTest::FIXTURES_DIR}/plain_file.txt.aes")
        end

        it 'should not be encrypted' do
          expect(@ysf.encrypted?).to eq(false)
        end

        context 'and then I set encrypted to false' do
          before(:all) do
            @ysf.encrypted = false
          end
          context 'and then I set a provider' do
            before(:all) do
              @ysf.provider = Yasst::Provider::OpenSSL.new(
                passphrase: 'a s3mi str0ng pa5r5phrase'
              )
            end

            it 'should not be encrypted' do
              expect(@ysf.encrypted?).to eq(false)
            end
          end
        end

        context 'and then I set encrypted to true' do
          before(:all) do
            @ysf = YasstFile.new(
              "#{YasstTest::FIXTURES_DIR}/plain_file.txt.aes"
            )
            @ysf.encrypted = true
          end
          context 'and then I set a provider' do
            before(:all) do
              @ysf.provider = Yasst::Provider::OpenSSL.new(
                passphrase: 'a s3mi str0ng pa5r5phrase'
              )
            end

            it 'should be encrypted' do
              expect(@ysf.encrypted?).to eq(true)
            end
          end
        end

        context 'when I set use the OpenSSL provider' do
          before(:all) do
            @ysf = YasstFile.new(
              "#{YasstTest::FIXTURES_DIR}/plain_file.txt.aes"
            )
            @ysf.provider = Yasst::Provider::OpenSSL.new(
              passphrase: 'a s3mi str0ng pa5r5phrase'
            )
          end
          it 'should then be encrypted' do
            expect(@ysf.encrypted?).to eq(true)
          end
        end

        context 'when I set use the test provider with a compatible file' do
          before(:all) do
            @ysf = YasstFile.new(
              "#{YasstTest::FIXTURES_DIR}/plain_file.txt.enc"
            )
          end
          it 'should then be encrypted' do
            @ysf.provider = test_provider
            expect(@ysf.encrypted?).to eq(true)
          end
        end
      end
    end
  end

  describe 'encrypt' do
    describe 'default behaviour' do
      context 'using the OpenSSL Provider' do
        before(:all) do
          @plain_file = YasstFile.new(
            "#{YasstTest::FIXTURES_DIR}/plain_file.txt"
          )
          @plain_file.provider = Yasst::Provider::OpenSSL.new(
            passphrase: 'a s3mi str0ng pa5r5phrase'
          )
          @plain_file.encrypt_to = "#{YasstTest::FIXTURES_DIR}" \
            '/tmp/plain_file.txt.aes'
        end
        it 'should encrypt and return the path to the encrypted file' do
          expect(@plain_file.encrypted?).to eq(false)
          expect(@plain_file.encrypt).to eq(@plain_file.encrypt_to)
          expect(File.exist?(@plain_file.encrypt_to)).to eq(true)
        end
      end
    end

    describe 'using homomorphic encrypt method' do
      let(:plain_file) { YasstFile.new(plain_file_path) }
      it 'should raise NotImplementedError' do
        plain_file.provider = openssl_provider
        expect { plain_file.encrypt(:homomorphic) }
          .to raise_error(NotImplementedError)
      end
    end
  end

  describe 'decrypt' do
    describe 'default behaviour' do
      context 'using the OpenSSL Provider' do
        before(:all) do
          @crypto_file = YasstFile.new(
            "#{YasstTest::FIXTURES_DIR}/plain_file.txt.aes"
          )
          @crypto_file.provider = Yasst::Provider::OpenSSL.new(
            passphrase: 'a s3mi str0ng pa5r5phrase'
          )
          @crypto_file.decrypt_to = "#{YasstTest::FIXTURES_DIR}" \
            '/tmp/plain_file.txt'
        end
        it 'should decrypt and return the path to the decrypted file' do
          expect(@crypto_file.encrypted?).to eq(true)
          expect(@crypto_file.decrypt).to eq(@crypto_file.decrypt_to)
          expect(File.exist?(@crypto_file.decrypt_to)).to eq(true)
        end
        it 'should have the expected text in' do
          File.open(@crypto_file.decrypt_to) do |f|
            expect(f.read).to eq("This is a plain text file\n")
          end
        end
      end
    end
  end
end
