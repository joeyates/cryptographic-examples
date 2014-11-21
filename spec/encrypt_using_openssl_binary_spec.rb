require 'base64'
require 'open3'
require 'openssl'
require 'tempfile'

describe 'encrypting with openssl' do
  let(:plaintext) { 'ciao' }
  let(:password) { 'passwordpasswordpasswordpassword' }
  # We use a Tempfile for input to avoid problems with trailing newlines
  let(:input) { Tempfile.new('input') }
  let(:openssl_command) do
    <<-EOT
      openssl enc -aes-256-cbc \
        -pass pass:"#{password}" \
        -in #{input.path} \
        -e -base64 #{openssl_params}
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
  let(:openssl_salted_ciphertext) { Base64.strict_decode64(ciphertext_output) }
  let(:ciphertext_salt) { openssl_salted_ciphertext[8 .. 15] }
  let(:encrypted) { openssl_salted_ciphertext[16 .. -1] }

  context 'using a password' do
    context 'without -p' do
      let(:openssl_params) { '' }
      let(:ciphertext_output) { stdout[0] }

      it 'prints the salted ciphertext' do
        expect(openssl_salted_ciphertext).to start_with('Salted__')
      end

      include_examples 'decrypting with Ruby using password and salt' do
        let(:salt) { ciphertext_salt }
      end

      include_examples 'decrypting openssl salted ciphertext with CryptoJS using password and salt'
    end

    context 'with -p' do
      let(:openssl_params) { '-p' }

      let(:salt_output) { hex_to_raw(part_after_equals(stdout[0])) }
      let(:key_output) { hex_to_raw(part_after_equals(stdout[1])) }
      let(:iv_output) { hex_to_raw(part_after_equals(stdout[2])) }
      let(:ciphertext_output) { stdout[3] }

      it 'prints the salt' do
        expect(stdout[0]).to start_with('salt=')
      end

      it 'prints the key' do
        expect(stdout[1]).to start_with('key=')
      end

      it 'prints the iv' do
        expect(stdout[2]).to start_with('iv =')
      end

      it 'prints the salted ciphertext' do
        expect(openssl_salted_ciphertext).to start_with('Salted__')
      end

      specify 'the printed salt matches the salt in the ciphertext' do
        expect(ciphertext_salt).to eq(salt_output)
      end

      include_examples 'decrypting with Ruby using password and salt' do
        let(:salt) { ciphertext_salt }
      end

      include_examples 'decrypting with Ruby using key and iv' do
        let(:key) { key_output }
        let(:iv) { iv_output }
      end

      include_examples 'decrypting openssl salted ciphertext with CryptoJS using password and salt'
      include_examples 'decrypting unsalted ciphertext with CryptoJS using key and iv' do
        let(:key) { key_output }
        let(:iv) { iv_output }
      end
      include_examples 'decrypting openssl salted ciphertext with CryptoJS using key and iv'
    end
  end
end
