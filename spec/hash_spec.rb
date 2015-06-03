require_relative '../model/credit_card'
require 'minitest/autorun'

describe 'Test hashing requirements' do
  before do
    @cc1 = CreditCard.new(
     number: '4916603231464963',
     expiration_date: 'Mar-30-2020',
     owner: 'Soumya Ray',
     credit_network: 'Visa'
   )
    @cc2 = CreditCard.new(
    number: '4916603231464963',
    expiration_date: 'Mar-30-2020',
    owner: 'Soumya Ray',
    credit_network: 'Visa'
    )
    @cc3 = CreditCard.new(
     number: '5423661657234057',
     expiration_date: 'Mar-30-2020',
     owner: 'Soumya Ray',
     credit_network: 'Visa'
    )
  end

  describe 'Test regular hashing' do
    it 'should find the same hash for identical cards' do
      # TODO: implement this test
      card1 = @cc1.hash
      card2 = @cc2.hash
      card1.must_equal card2
    end

    it 'should produce different hashes for different information' do
      # TODO: implement this test
      card1 = @cc1.hash
      card2 = @cc3.hash
      card1.wont_equal card2
    end
  end

  describe 'Test cryptographic hashing' do
    it 'should find the same hash for identical cards' do
      # TODO: implement this test
      card1 = @cc1.secure_hash
      card2 = @cc2.secure_hash
      card1.must_equal card2
    end

    it 'should produce different hashes for different information' do
      # TODO: implement this test
      card1 = @cc1.secure_hash
      card2 = @cc3.secure_hash
      card1.wont_equal card2
    end

    it 'should not produce the same regular vs. cryptographic hash' do
      # TODO: implement this test
      h1 = @cc1.hash
      h2 = @cc1.secure_hash
      h1.wont_equal h2
    end
  end
end
