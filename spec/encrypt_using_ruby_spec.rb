require 'base64'
require 'openssl'

describe 'encrypting with Ruby' do
  let(:plaintext) { 'ciao' }
  let(:encryptor ) { OpenSSL::Cipher::AES.new(256, :CBC).encrypt }
  let(:decryptor) { OpenSSL::Cipher::AES.new(256, :CBC).decrypt }
  let(:password) { 'passwordpasswordpasswordpassword' }
  let(:salt) { Random.new.bytes(8) }
  let(:key) { Random.new.bytes(32) }
  let(:iv) { Random.new.bytes(16) }

  shared_examples 'decrypting with Ruby using password and salt' do
    context 'decrypting with Ruby using password and salt' do

      # N.B. pkcs5_keyivgen is deprected
      it 'decrypts correctly' do
        # openssl does one iteration when derivind key and iv from a password
        decryptor.pkcs5_keyivgen(password, salt, 1)
        result = decryptor.update(encrypted)
        result << decryptor.final

        expect(result).to eq(plaintext)
      end
    end
  end

  shared_examples 'decrypting with Ruby using key and iv' do
    context 'decrypting with Ruby using generated key and iv' do
      it 'decrypts correctly' do
        decryptor.key = key
        decryptor.iv = iv

        result = decryptor.update(encrypted)
        result << decryptor.final

        expect(result).to eq(plaintext)
      end
    end
  end

  context 'using pkcs5_keyivgen with password and salt' do
    let(:encrypted) do
      encryptor.pkcs5_keyivgen(password, salt, 1)
      encrypted = encryptor.update(plaintext)
      encrypted << encryptor.final
    end

    include_examples 'decrypting with Ruby using password and salt'
    # As pkcs5_keyivgen doesn't show us the generated key and iv
    # we can't use them to decrypt
    #include_examples 'decrypting with Ruby using key and iv'

    context 'decrypting with CryptoJS using password and salt' do
      let(:js) { v8_with_cryptojs }
      let(:openssl_ciphertext) { 'Salted__' + salt + encrypted }
      let(:ciphertext_base64) { Base64.strict_encode64(openssl_ciphertext) }
      let(:code) do
        <<-EOT
var ciphertext_base64 = '#{ciphertext_base64}';
var password = '#{password}';
var plaintext = CryptoJS.AES.decrypt(ciphertext_base64, password);
        EOT
      end

      it 'decrypts correctly' do
        js.eval(code)
        result = js.eval('plaintext.toString(CryptoJS.enc.Utf8)')
        expect(result).to eq(plaintext)
      end
    end
  end

  context 'using random key and iv' do
    let(:encrypted) do
      encryptor.key = key
      encryptor.iv = iv
      encrypted = encryptor.update(plaintext)
      encrypted << encryptor.final
    end

    include_examples 'decrypting with Ruby using key and iv'
  end
end
