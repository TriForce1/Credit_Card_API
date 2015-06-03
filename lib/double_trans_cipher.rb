# This is the Double Transposition Cipher Module
module DoubleTranspositionCipher
  def self.encrypt(document, key)
    # TODO: FILL THIS IN!
    ## Suggested steps for double transposition cipher
    # 1. find number of rows/cols such that matrix is almost square
    # 2. break plaintext into evenly sized blocks
    # 3. sort rows in predictibly random way using key as seed
    # 4. sort columns of each row in predictibly random way
    # 5. return joined cyphertext

    document = document.to_s # converting the document to a string
    squarert = Math.sqrt(document.length)

    row = squarert.round # finding number of rows & rounding it up
    col = 0
    squarert == squarert.to_i ? col = row : col = (document.length / row) + 1

    # breaking up doc into a matrix that is almost a square
    document = document.chars.to_a.each_slice(col).to_a

    # randomly shuffling rows first, then columns within rows
    document.shuffle!(random: Random.new(key))
    document.map! { |d| d.shuffle(random: Random.new(key)) }.join
  end

  def self.decrypt(ciphertext, key)
    # TODO: FILL THIS IN!
    ciphertext = ciphertext.to_s.chars.to_a # converting to array of chars
    squarert = Math.sqrt(ciphertext.length)
    row = squarert.round
    col = 0
    squarert == squarert.to_i ? col = row : col = (ciphertext.length / row) + 1

    # breaking up arr into a matrix that is almost a square
    arr = (1..ciphertext.length).to_a.each_slice(col).to_a

    # randomly shuffling rows first, then columns within rows
    arr.shuffle!(random: Random.new(key))
    arr.map! { |d| d.shuffle(random: Random.new(key)) }.flatten!

    document = [] # new array to store original doc
    counter = 1
    arr.each do
      document << ciphertext[arr.index(counter)]
      counter += 1
    end

    document.join
  end

end
