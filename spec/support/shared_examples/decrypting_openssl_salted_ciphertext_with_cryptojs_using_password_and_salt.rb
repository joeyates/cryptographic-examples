shared_examples 'decrypting openssl salted ciphertext with CryptoJS using password and salt' do
  context 'decrypting openssl salted ciphertext with CryptoJS using password and salt' do
    # The ciphertext contains the salt (bytes 8 to 15)
    let(:js) { v8_with_cryptojs }
    let(:openssl_salted_ciphertext_base64) { Base64.strict_encode64(openssl_salted_ciphertext) }
    let(:decryption_code) do
      <<-EOT
var ciphertext_base64 = '#{openssl_salted_ciphertext_base64}';
var password = '#{password}';
var plaintext = CryptoJS.AES.decrypt(ciphertext_base64, password);
      EOT
    end

    it 'decrypts correctly' do
      js.eval(decryption_code)
      result = js.eval('plaintext.toString(CryptoJS.enc.Utf8)')
      expect(result).to eq(plaintext)
    end
  end
end
