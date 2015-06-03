require_relative '../model/credit_card'
require_relative '../lib/substitution_cipher'
require_relative '../lib/aes_cipher'
require_relative '../lib/double_trans_cipher'
require 'minitest/autorun'
require 'yaml'

passwords = YAML.load_file 'spec/test_passwords.yml'

describe 'Test card info encryption' do
  before do
    @cc = CreditCard.new(
     number: '4916603231464963',
     expiration_date: 'Mar-30-2020',
     owner: 'Soumya Ray',
     credit_network: 'Visa'
   )

    @key = 3
    @key2 = 'I am a very very special key'
  end

  describe 'Using Caeser cipher' do
    it 'should encrypt card information' do
      enc = SubstitutionCipher::Caeser.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = SubstitutionCipher::Caeser.encrypt(@cc, @key)
      dec = SubstitutionCipher::Caeser.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end
  end

  describe 'Using Permutation cipher' do
    it 'should encrypt card information' do
      enc = SubstitutionCipher::Permutation.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = SubstitutionCipher::Permutation.encrypt(@cc, @key)
      dec = SubstitutionCipher::Permutation.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end
  end
  describe 'Using Double Transposition cipher' do
    it 'should encrypt card information' do
      enc = DoubleTranspositionCipher.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = DoubleTranspositionCipher.encrypt(@cc, @key)
      dec = DoubleTranspositionCipher.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end

    it 'should have card info to encrypt' do
      @cc.to_s.wont_equal ''
    end
  end
  passwords.each do |owner, pass|
    describe "Using Aes cipher to encrypt #{owner} password" do
      pass.each do |pa|
        it 'should encrypt card information' do
          enc = AesCipher.encrypt(pa, @key2)
          enc.wont_equal pa
        end
        it 'should decrypt text' do
          enc = AesCipher.encrypt(pa, @key2)
          dec = AesCipher.decrypt(enc, @key2)
          dec.must_equal pa.to_s
        end
      end
    end
  end
end
