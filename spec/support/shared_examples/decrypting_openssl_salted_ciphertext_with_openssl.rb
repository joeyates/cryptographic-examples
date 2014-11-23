shared_examples 'decrypting openssl ciphertext using openssl with password' do
  context 'decrypting openssl ciphertext using openssl with password' do
    let(:openssl_decryption_command) do
      openssl_command = <<-EOT
echo '#{ciphertext_output}' | openssl enc -aes-256-cbc \
  -pass pass:"#{password}" \
  -d -base64
      EOT
      command = ShellCommand.new(openssl_command)
      command.run
      command
    end

    it 'decrypts correctly' do
      expect(openssl_decryption_command.stdout[0]).to eq(plaintext)
    end
  end
end
