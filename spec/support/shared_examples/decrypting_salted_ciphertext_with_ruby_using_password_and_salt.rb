shared_examples 'decrypting salted ciphertext with Ruby using password and salt' do
  context 'decrypting salted ciphertext with Ruby using password and salt' do
    let(:decryptor) { OpenSSL::Cipher::AES.new(256, :CBC).decrypt }

    # N.B. pkcs5_keyivgen is deprected
    it 'decrypts correctly' do
      decryptor.pkcs5_keyivgen(password, salt, 1)
      result = decryptor.update(encrypted)
      result << decryptor.final

      expect(result).to eq(plaintext)
    end
  end
end
