require 'base64'
require 'rbnacl/libsodium'
require 'json'
require 'sinatra/activerecord'
require_relative '../environments'

# Helper module for Models
module ModelHelper
  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
  end

  def enc64(value)
    Base64.urlsafe_encode64(value)
  end

  def dec64(value)
    Base64.urlsafe_decode64(value)
  end
end
