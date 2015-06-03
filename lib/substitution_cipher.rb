module SubstitutionCipher
  module Caeser
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)
      # TODO: encrypt string using caeser cipher
      # Performing calculation to find new ord number
      new_doc = document.to_s.chars.map { |d| ((d.ord - 32) + key) % 95 + 32 }
      # using the new ord number as a key to get the char from hash
      new_doc.map(&:chr).join
    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using caeser cipher
      # Performing reverse calculation to find old ord number
      new_doc = document.to_s.chars.map { |d| ((d.ord  - 32) - key) % 95 + 32 }
      # using the old ord number as a key to get the original char
      new_doc.map(&:chr).join
    end
  end

  module Permutation
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)
      # TODO: encrypt string using caeser cipher
      # original ascii ord
      ori = (0..127).to_a
      # randomly shuffling ords in parallel array
      new_ar = ori.shuffle(random: Random.new(key))
      # mapping each char->ord and using its index to search parall.array
      new_doc = document.to_s.chars.map { |d| new_ar[ori.index(d.ord)] }
      # joining all chars to implicitly return a string
      new_doc.map(&:chr).join
    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using caeser cipher
      # original ascii ord
      ori = (0..127).to_a
      # randomly shuffling ords in parallel array
      new_ar = ori.shuffle(random: Random.new(key))
      # mapping each char->ord and using its index to search parall.array
      new_doc = document.to_s.chars.map { |d| ori[new_ar.index(d.ord)] }
      # joining all chars to implicitly return a string
      new_doc.map(&:chr).join
    end
  end
end
