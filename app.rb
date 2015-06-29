require 'sinatra'
require 'sinatra/param'
require_relative './model/credit_card'
require 'config_env'
require 'rdiscount'
require_relative './helpers/app_helper'
require 'rack/ssl-enforcer'
require 'dalli'

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

    set :ops_cache,
        Dalli::Client.new((ENV['MEMCACHIER_SERVERS'] || '').split(','),
                          username: ENV['MEMCACHIER_USERNAME'],
                          password: ENV['MEMCACHIER_PASSWORD'],
                          socket_timeout: 1.5,
                          socket_failure_delay: 0.2
                         )
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
      settings.ops_cache.set(user_id, cc.map(&:to_s).to_json)
      cc.map(&:to_s).to_json
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
      if card.save
        cc = CreditCard.where(user_id: card.user_id)
        settings.ops_cache.set(card.user_id, cc.map(&:to_s).to_json)
        status 201
      end
    rescue => e
      logger.error(e)
      halt 410
    end
  end
end
