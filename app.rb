require 'sinatra'
require 'sinatra/param'
require_relative './model/credit_card'
require 'config_env'
require 'rdiscount'
require_relative './helpers/app_helper'
require 'rack/ssl-enforcer'

configure :development, :test do
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end

# Old CLIs now on Web
class CreditCardAPI < Sinatra::Base
  enable :logging
  include AppHelper

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  configure do
    require 'hirb'
    Hirb.enable
    # use Rack::Session::Cookie, secret: settings.session_secret
    # use Rack::Session::Cookie, secret: ENV['MSG_KEY']
  end

  helpers Sinatra::Param

  get '/' do
    markdown :INDEX
  end

  get '/api/v1/credit_card/?' do
    if params[:user_id]
      halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
      user_id = @user_id
      cc = CreditCard.where(user_id: user_id)
      cc.map(&:to_s)
    else
      markdown :API
    end
  end

  get '/api/v1/credit_card/validate/?' do
    logger.info('VALIDATE')
    begin
      halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
      # param :card_number, Integer
      # fail('Pass a card number') unless params[:card_number]
      card = CreditCard.new(number: "#{params[:number]}")
      { number: card.number, validate_checksum: card.validate_checksum }.to_json
    rescue => e
      logger.error(e)
      redirect '/api/v1/credit_card/'
    end
  end

  post '/api/v1/credit_card/?' do
    content_type :json
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    details_json = JSON.parse(request.body.read)

    begin
      card = CreditCard.new(number: "#{details_json['number']}",
                            expiration_date:
                            "#{details_json['expiration_date']}",
                            credit_network: "#{details_json['credit_network']}",
                            owner: "#{details_json['owner']}")
      card.user_id = @user_id
      halt 400 unless card.validate_checksum
      status 201 if card.save
    rescue => e
      logger.error(e)
      halt 410
    end
  end
end
