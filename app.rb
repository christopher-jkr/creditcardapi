require 'sinatra'
require_relative './lib/credit_card'

# Old CLIs now on Web
class CreditCardAPI < Sinatra::Base
  get '/' do
    'The Credit Card API is running at <a href="/api/v1/credit_card/">
    /api/v1/credit_card/</a>'
  end

  get '/api/v1/credit_card/?' do
    'Right now, the professor says to just let you validate credit
    card numbers and you can do that at with: <br />
    GET /api/v1/credit_card/validate?card_number=[your card number]'
  end

  get '/api/v1/credit_card/validate/?' do
    card_number = params[:card_number]
    halt 400 unless card_number

    card = CreditCard.new(card_number, nil, nil, nil)
    { "card": card_number,
      "validated": card.validate_checksum
    }.to_json
  end
end
