require 'base64'
require 'open3'
require 'openssl'
require 'tempfile'
require 'v8'

describe 'encrypting with openssl' do
  def part_after_equals(text)
    text.scan(/=(.*)/)[0][0]
  end

  def hex_to_raw(text)
    [text].pack('H*')
  end

  let(:plaintext) { 'ciao' }
  let(:password) { 'passwordpasswordpasswordpassword' }
  let(:input) { Tempfile.new('input') }
  let(:openssl_command) do
    <<-EOT
      openssl enc -aes-256-cbc \
        -pass pass:"#{password}" \
        -in #{input.path} \
        -e -base64 -p
    EOT
  end
  let(:openssl_results) do
    input.write plaintext
    input.close
    _, out, err, wait_thr = Open3.popen3(openssl_command)
    stdout = out.read
    stderr = err.read
    input.unlink
    [stdout, stderr, wait_thr.value.exitstatus]
  end
  let(:stdout) { openssl_results[0].split("\n") }
  let(:openssl_exit_status) { openssl_results[2] }
  let(:generated_salt) { hex_to_raw(part_after_equals(stdout[0])) }
  let(:generated_key) { hex_to_raw(part_after_equals(stdout[1])) }
  let(:generated_iv) { hex_to_raw(part_after_equals(stdout[2])) }
  let(:ciphertext_base64) { stdout[3] }
  let(:ciphertext) { Base64.strict_decode64(ciphertext_base64) }
  let(:ciphertext_salt) { ciphertext[8 .. 15] }
  let(:encrypted) { ciphertext[16 .. -1] }
  let(:decrypter) { OpenSSL::Cipher::AES.new(256, :CBC).decrypt }

  let(:root) { Pathname.new(File.dirname(__dir__)) }
  let(:cryptojs_pathname) { root.join('bower_components', 'crypto-js', 'rollups', 'aes.js') }

  context 'using a password and -p' do
    it 'prints the salt' do
      expect(stdout[0]).to start_with('salt=')
    end

    it 'prints the key' do
      expect(stdout[1]).to start_with('key=')
    end

    it 'prints the iv' do
      expect(stdout[2]).to start_with('iv =')
    end

    it 'prints the salted cyphertext' do
      expect(ciphertext).to start_with('Salted__')
    end

    context 'decrypting with Ruby' do
      context 'using key and iv' do
        it 'decrypts correctly' do
          decrypter.key = generated_key
          decrypter.iv = generated_iv
          result = decrypter.update(encrypted)
          result << decrypter.final

          expect(result).to eq(plaintext)
        end
      end

      context 'using password' do
        # N.B. pkcs5_keyivgen is deprected
        it 'decrypts correctly' do
          # openssl does one iteration when derivind key and iv from a password
          decrypter.pkcs5_keyivgen(password, ciphertext_salt, 1)
          result = decrypter.update(encrypted)
          result << decrypter.final

          expect(result).to eq(plaintext)
        end
      end
    end

    context 'decrypting with Javascript' do
      let(:js) { V8::Context.new }
      let(:generated_key_base64) { Base64.strict_encode64(generated_key) }
      let(:generated_iv_base64) { Base64.strict_encode64(generated_iv) }

      before do
        js.load(cryptojs_pathname.to_s)
      end

      context 'using key and iv' do
        let(:code) do
          <<-EOT
var key = CryptoJS.enc.Base64.parse('#{generated_key_base64}')
var iv = CryptoJS.enc.Base64.parse('#{generated_iv_base64}')
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

      context 'using password' do
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
  end
end
