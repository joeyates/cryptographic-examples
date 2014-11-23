shared_examples 'decrypting openssl salted ciphertext with Ruby using password and salt' do
  context 'decrypting openssl salted ciphertext with Ruby using password and salt' do
    let(:decryptor) { OpenSSL::Cipher::AES.new(256, :CBC).decrypt }
    let(:ciphertext_salt) { openssl_salted_ciphertext[8 .. 15] }
    let(:encrypted) { openssl_salted_ciphertext[16 .. -1] }

    # N.B. pkcs5_keyivgen is deprected
    it 'decrypts correctly' do
      # openssl does one iteration when deriving key and iv from a password
      decryptor.pkcs5_keyivgen(password, ciphertext_salt, 1)
      result = decryptor.update(encrypted)
      result << decryptor.final

      expect(result).to eq(plaintext)
    end
  end
end
