shared_examples 'decrypting salted ciphertext with CryptoJS using password and salt' do
  context 'decrypting salted ciphertext with CryptoJS using password and salt' do
    let(:js) { v8_with_cryptojs }
    let(:salt_base64) { Base64.strict_encode64(salt) }
    let(:ciphertext_base64) { Base64.strict_encode64(ciphertext) }
    let(:setup_code) do
      <<-EOT
var salt_base64 = '#{salt_base64}';
var ciphertext_base64 = '#{ciphertext_base64}';
var password = '#{password}';
var salt = CryptoJS.enc.Base64.parse(salt_base64);
      EOT
    end

    before { js.eval(setup_code) }

    context 'when passing the salt as a parameter' do
      let(:decryption_code) do
        <<-EOT
var password_word_array = CryptoJS.enc.Base64.parse(password);
var plaintext = CryptoJS.AES.decrypt(ciphertext_base64, password_word_array, {salt: salt});
        EOT
      end

      it 'decrypts correctly' do
        pending "You would need to write a CryptoJS formatter to get non-openssl salted ciphertext to work"
        js.eval(decryption_code)
        result = js.eval('plaintext.toString(CryptoJS.enc.Utf8)')
        expect(result).to eq(plaintext)
      end
    end

    context 'via creation of an openssl-style salted ciphertext' do
      let(:decryption_code) do
        <<-EOT
var prefix = CryptoJS.enc.Utf8.parse('Salted__');
var ciphertext = CryptoJS.enc.Base64.parse(ciphertext_base64);
var openssl_salted_ciphertext_word_array = prefix.concat(salt).concat(ciphertext);
var openssl_salted_ciphertext_base64 = CryptoJS.enc.Base64.stringify(openssl_salted_ciphertext_word_array);
var plaintext = CryptoJS.AES.decrypt(openssl_salted_ciphertext_base64, password);
        EOT
      end

      it 'decrypts correctly' do
        puts "salt_base64: #{salt_base64}"
        puts "ciphertext_base64: #{ciphertext_base64}"
        js.eval(decryption_code)
        result = js.eval('plaintext.toString(CryptoJS.enc.Utf8)')
        expect(result).to eq(plaintext)
      end
    end
  end
end

