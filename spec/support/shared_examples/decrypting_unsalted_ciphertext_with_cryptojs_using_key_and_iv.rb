require 'base64'

shared_examples 'decrypting unsalted ciphertext with CryptoJS using key and iv' do
  context 'decrypting unsalted ciphertext with CryptoJS using key and iv' do
    let(:js) { v8_with_cryptojs }
    let(:key_base64) { Base64.strict_encode64(key) }
    let(:iv_base64) { Base64.strict_encode64(iv) }
    let(:ciphertext_base64) { Base64.strict_encode64(encrypted) }

    let(:code) do
      <<-EOT
var key = CryptoJS.enc.Base64.parse('#{key_base64}')
var iv = CryptoJS.enc.Base64.parse('#{iv_base64}')
var ciphertext_base64 = '#{ciphertext_base64}'
// key and iv are CryptoJS 'WordArray' objects
// CryptoJS.AES.decrypt recognises that key is not a plaintext password
// and uses it as binary bytes, along with iv
var plaintext = CryptoJS.AES.decrypt(ciphertext_base64, key, {iv: iv})
      EOT
    end

    it 'decrypts correctly' do
      js.eval(code)
      result = js.eval('plaintext.toString(CryptoJS.enc.Utf8)')
      expect(result).to eq(plaintext)
    end
  end
end
