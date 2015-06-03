require 'base64'
require_relative '../lib/luhn_validator.rb'
require 'json'
require 'openssl'
require 'sinatra/activerecord'
require 'rbnacl/libsodium'
require_relative '../environments'

# Credit Card Class
class CreditCard < ActiveRecord::Base
  # TODO: mixin the LuhnValidator using an 'include' statement
    include LuhnValidator

  # instance variables with automatic getter/setter methods
  # attr_accessor :number, :expiration_date, :owner, :credit_network

  """def initialize(number, expiration_date, owner, credit_network)
    # TODO: initialize the instance variables listed above(don't forget the '@')
    @number = number
    @expiration_date = expiration_date
    @owner = owner
    @credit_network = credit_network
  end"""
  #Function to Make copy of DB_KEY
  #Function to Make copy of DB_KEY
  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
  end

  # Encrypts credit card number for storage
  def number=(number_str)
    secret_box = RbNaCl::SecretBox.new(key)
    self.nonce = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
    # puts nonce
    self.encrypted_number = Base64.encode64(secret_box.encrypt(self.nonce, number_str))
    # puts encrypted_number
    self.nonce = Base64.encode64(self.nonce)
    # puts nonce
  end

  # Decrypts credit card
  def number
    secret_box = RbNaCl::SecretBox.new(key)
    secret_box.decrypt(Base64.decode64(self.nonce), Base64.decode64(self.encrypted_number))
  end

  # returns json string
  def to_json
    {
      # TODO: setup the hash with all instance vairables to serialize into json
      'Name' => owner,
      'Card_Number' => number,
      'Expiration_Date' => expiration_date,
      'Credit_Card_Network' => credit_network
    }.to_json
  end

  # returns all card information as single string
  def to_s
    to_json
  end

  # return a new CreditCard object given a serialized (JSON) representation
  def self.from_s(card_s)
    # TODO: deserializing a CreditCard object
    cc = JSON.parse(card_s)
    CreditCard.new(number: cc['Card_Number'], expiration_date: cc['Expiration_Date'],
                   owner: cc['Name'],credit_network: cc['Credit_Card_Network'])
  end

  # overrides the default hash method
  def hash
    to_s.hash
  end

  # Creates a SHA256 hash
  def secure_hash
    sha256 = OpenSSL::Digest::SHA256.new
    sha256.digest(to_s).unpack('H*')
  end

end
