require 'openssl'
require 'json'

# This is the AesCipher Module
module AesCipher
  def self.encrypt(document, key)
    # TODO: Return JSON string of array: [iv, ciphertext]
    #       where iv is the random intialization vector used in AES
    #       and ciphertext is the output of AES encryption
    # NOTE: Use hexadecimal strings for output so that it is screen printable
    #       Use cipher block chaining mode only!

    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    cipher.key = key
    initvec = cipher.random_iv
    ciphertext = cipher.update(document) + cipher.final
    [initvec.unpack('H*'), ciphertext.unpack('H*')].to_json
  end

  def self.decrypt(aes_crypt, key)
    # TODO: decrypt from JSON output (aes_crypt) of encrypt method above
    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = key
    input = JSON.parse(aes_crypt)
    decipher.iv = input[0].pack('H*')
    decipher.update(input[1].pack('H*')) + decipher.final
  end
end
