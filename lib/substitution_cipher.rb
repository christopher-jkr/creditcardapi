module SubstitutionCipher
  module Caesar
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)
      key %= 127
      document.to_s.chars.map do |x|
        a = x.ord + key
        a -= 127 if a > 127
        a.chr
      end.join
    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using caesar cipher
      key %= 127
      document.chars.map do |x|
        a = x.ord - key
        a += 127 if a < 0
        a.chr
      end.join
    end
  end

  module Permutation
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String

    def self.int_loop(key_l, r, c)
      # Iterator to create unique random values
      begin
        a = r.rand(128)
        c[key_l] = a unless c.value?(a)
      end until c.key?(key_l)
    end

    def self.fill_book(key, cb)
      # Fill code book
      rand1 = Random.new(key)
      (32..127).each do |x|
        int_loop(x, rand1, cb)
      end
      cb
    end

    def self.encrypt(document, key)
      code_book = {}
      fill_book(key, code_book)
      document.to_s.chars.map { |x| code_book[x.ord].chr }.join
    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      code_book = {}
      fill_book(key, code_book)
      document.chars.map { |x| (code_book.key(x.ord)).chr }.join
    end
  end
end
