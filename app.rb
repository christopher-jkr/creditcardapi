require 'sinatra'
require 'sinatra/param'
require_relative './model/credit_card'
require_relative './model/user'
require 'config_env'

# Old CLIs now on Web
class CreditCardAPI < Sinatra::Base
  configure :development, :test do
    require 'hirb'
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
    Hirb.enable
  end

  helpers Sinatra::Param
  get '/' do
    'The Credit Card API is running at <a href="/api/v1/credit_card/">
    /api/v1/credit_card/</a>'
  end

  get '/api/v1/credit_card/?' do
    'Right now, the professor says to just let you validate credit
    card numbers and you can do that with: <br />
    GET /api/v1/credit_card/validate?card_number=[your card number]'
  end

  get '/api/v1/credit_card/validate/?' do
    param :card_number, Integer
    halt 400 unless params[:card_number]

    card = CreditCard.new(number: "#{params[:card_number]}")

    { "card": card.number,
      "validated": card.validate_checksum
    }.to_json
  end

  post '/api/v1/credit_card/?' do
    details_json = JSON.parse(request.body.read)

    begin
      card = CreditCard.new(number: "#{details_json['number']}",
                            expiration_date:
                            "#{details_json['expiration_date']}",
                            credit_network: "#{details_json['credit_network']}",
                            owner: "#{details_json['owner']}")
      halt 400 unless card.validate_checksum
      status 201 if card.save
    rescue
      halt 410
    end
  end

  post '/api/v1/user/?' do
    details_json = JSON.parse(request.body.read)

    begin
      user = User.new(username: "#{details_json['username']}",
                      email: "#{details_json['email']}")
      user.password = "#{details_json['password']}"
      user.dob = "#{details_json['dob']}"
      user.address = "#{details_json['address']}"
      user.fullname = "#{details_json['fullname']}"
      status 201 if user.save
    rescue
      halt 410
    end
  end

  get '/api/v1/credit_card/all/?' do
    begin
      CreditCard.all.map(&:to_s)
    rescue
      halt 500
    end
  end

  get '/api/v1/user/all/?' do
    begin
      User.all.map(&:to_s)
    rescue
      halt 500
    end
  end
end
