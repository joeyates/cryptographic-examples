shared_examples 'decrypting with Ruby using key and iv' do
  context 'decrypting with Ruby using key and iv' do
    let(:decryptor) { OpenSSL::Cipher::AES.new(256, :CBC).decrypt }

    it 'decrypts correctly' do
      decryptor.key = key
      decryptor.iv = iv
      result = decryptor.update(encrypted)
      result << decryptor.final

      expect(result).to eq(plaintext)
    end
  end
end
