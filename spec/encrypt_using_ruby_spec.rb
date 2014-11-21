require 'openssl'

describe 'encrypting with Ruby' do
  let(:plaintext) { 'ciao' }
  let(:encryptor) { OpenSSL::Cipher::AES.new(256, :CBC).encrypt }
  let(:password) { 'passwordpasswordpasswordpassword' }
  let(:salt) { Random.new.bytes(8) }
  let(:key) { Random.new.bytes(32) }
  let(:iv) { Random.new.bytes(16) }

  context 'using pkcs5_keyivgen with password and salt' do
    let(:encrypted) do
      encryptor.pkcs5_keyivgen(password, salt, 1)
      encrypted = encryptor.update(plaintext)
      encrypted << encryptor.final
    end

    include_examples 'decrypting with Ruby using password and salt'

    # As pkcs5_keyivgen doesn't show us the generated key and iv
    # we can't use them to decrypt
    #include_examples 'decrypting with Ruby using key and iv'

    include_examples 'decrypting with CryptoJS using password and salt' do
      let(:openssl_salted_ciphertext) { 'Salted__' + salt + encrypted }
    end
  end

  context 'using random key and iv' do
    let(:encrypted) do
      encryptor.key = key
      encryptor.iv = iv
      encrypted = encryptor.update(plaintext)
      encrypted << encryptor.final
    end

    include_examples 'decrypting with Ruby using key and iv'
    include_examples 'decrypting with CryptoJS using key and iv' do
      let(:openssl_salted_ciphertext) { 'Salted__' + salt + encrypted }
    end
  end
end
