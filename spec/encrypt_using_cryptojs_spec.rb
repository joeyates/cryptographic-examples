require 'base64'

describe 'encrypting with CryptoJS' do
  let(:plaintext) { 'ciao' }
  let(:password) { 'passwordpasswordpasswordpassword' }
  let(:js) { v8_with_cryptojs }
  let(:output) { js.eval(encryption_code) }

  context 'using password' do
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

      include_examples 'decrypting with CryptoJS using password and salt' do
        let(:openssl_salted_ciphertext) { decoded_output }
      end
    end
  end
end
