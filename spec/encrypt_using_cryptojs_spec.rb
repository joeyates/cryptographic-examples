require 'base64'

describe 'encrypting with CryptoJS' do
  let(:plaintext) { 'ciao' }
  let(:js) { v8_with_cryptojs }
  let(:output) { js.eval(encryption_code) }

  context 'using password' do
    let(:password) { 'passwordpasswordpasswordpassword' }
    let(:encryption_code) do
      <<-EOT
var plaintext = '#{plaintext}';
var password = '#{password}';
var encrypted = CryptoJS.AES.encrypt(plaintext, password);
encrypted.toString();
      EOT
    end

    context 'with default encoding' do
      let(:decoded_output) { Base64.strict_decode64(output) }
      let(:ciphertext_salt) { decoded_output[8 .. 15] }

      it 'outputs a Base64 encoded string' do
        expect { Base64.strict_decode64(output) }.to_not raise_error
      end

      it 'outputs openssl-style salted ciphertext' do
        expect(decoded_output).to start_with('Salted__')
      end

      include_examples 'decrypting with Ruby using password and salt' do
        let(:encrypted) { decoded_output[16 .. -1] }
        let(:salt) { ciphertext_salt }
      end

      include_examples 'decrypting openssl salted ciphertext with CryptoJS using password and salt' do
        let(:openssl_salted_ciphertext) { decoded_output }
      end
    end
  end

  context 'using a key and iv' do
    let(:key) { Random.new.bytes(32) }
    let(:iv) { Random.new.bytes(16) }
    let(:key_base64) { Base64.strict_encode64(key) }
    let(:iv_base64) { Base64.strict_encode64(iv) }
    let(:encryption_code) do
      <<-EOT
var plaintext = '#{plaintext}';
var key = CryptoJS.enc.Base64.parse('#{key_base64}');
var iv = CryptoJS.enc.Base64.parse('#{iv_base64}');
var encrypted = CryptoJS.AES.encrypt(plaintext, key, {iv: iv});
encrypted.toString();
      EOT
    end
    let(:decoded_output) { Base64.strict_decode64(output) }

    it 'outputs unsalted ciphertext' do
      expect(decoded_output).to_not start_with('Salted__')
    end

    include_examples 'decrypting with Ruby using key and iv' do
      let(:encrypted) { decoded_output }
    end
  end
end
