require 'openssl'
require 'json'

module AesCipher
  def self.encrypt(document, key)
    document = document.to_s
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.key = Digest::SHA256.hexdigest(key.to_s)
    iv = cipher.random_iv
    encrypted = (cipher.update(document) + cipher.final)
    my_hash = {
      iv: iv.unpack('H*'), ciphertext: encrypted.unpack('H*')
    }
    JSON.generate(my_hash)
  end

  def self.decrypt(aes_crypt, key)
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = (Digest::SHA256.hexdigest(key.to_s))
    aes_crypt = JSON.parse(aes_crypt)
    decipher.iv = aes_crypt['iv'].pack('H*')
    dec_t = aes_crypt['ciphertext'].pack('H*')
    decipher.update(dec_t) + decipher.final
  end
end
