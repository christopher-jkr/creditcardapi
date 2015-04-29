require 'sinatra/activerecord'
require_relative '../environments'
require_relative '../lib/luhn_validator.rb'
require 'json'
require 'openssl'
require 'forwardable'
require 'rbnacl/libsodium'
require 'base64'

# Credit Card class, the basis for humanity
class CreditCard < ActiveRecord::Base
  include LuhnValidator
  extend Forwardable

  def key
    ENV['DB_KEY'].dup.force_encoding Encoding::BINARY
  end

  def number=(params)
    enc = RbNaCl::SecretBox.new(key)
    nonce = RbNaCl::Random.random_bytes(enc.nonce_bytes)
    self.nonce_64 = Base64.encode64(nonce)
    self.encrypted_number = Base64.encode64(enc.encrypt(nonce, "#{params}"))
  end

  def number
    dec = RbNaCl::SecretBox.new(key)
    dec.decrypt(Base64.decode64(nonce_64), Base64.decode64(encrypted_number))
  end

  # returns json string
  # def to_json
  #   {
  #     number: @number, expiration_date: @expiration_date, owner: @owner,
  #     credit_number: @credit_number
  #   }.to_json
  # end

  # returns all card information as single string
  def to_s
    {
      number: number, owner: owner, expiration_date: expiration_date,
      credit_network: credit_network
    }.to_json
  end

  # return a new CreditCard object given a serialized (JSON) representation
  def self.from_s(card_s)
    new(*(JSON.parse(card_s).values))
  end

  # return a hash of the serialized credit card object
  delegate hash: :to_s

  # return a cryptographically secure hash
  def hash_secure
    sha256 = OpenSSL::Digest::SHA256.new
    sha256.digest(to_s).unpack('H*')[0]
  end
end
