require_relative '../lib/luhn_validator'
require 'openssl'
require 'forwardable'
require_relative '../helpers/model_helper'

# Credit Card class, the basis for humanity
class CreditCard < ActiveRecord::Base
  include ModelHelper, LuhnValidator
  extend Forwardable

  def number=(params)
    enc = RbNaCl::SecretBox.new(key)
    nonce = RbNaCl::Random.random_bytes(enc.nonce_bytes)
    self.nonce_64 = enc64(nonce)
    self.encrypted_number = enc64(enc.encrypt(nonce, "#{params}"))
  end

  def number
    dec = RbNaCl::SecretBox.new(key)
    dec.decrypt(dec64(nonce_64), dec64(encrypted_number))
  end

  # returns all card information as single string
  def to_s
    {
      number: number,
      owner: owner,
      expiration_date: expiration_date,
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
    enc64(sha256.digest)
  end
end
