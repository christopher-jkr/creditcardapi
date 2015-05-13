require 'sinatra'
require 'sinatra/param'
require_relative './model/credit_card'
require_relative './model/user'
require 'config_env'
require_relative './helpers/creditcard_helper.rb'

# Old CLIs now on Web
class CreditCardAPI < Sinatra::Base
  include CreditCardHelper
  use Rack::Session::Cookie
  enable :logging
  configure :development, :test do
    require 'hirb'
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
    Hirb.enable
  end
  helpers Sinatra::Param

  before do
    @current_user = session[:user_id] ? User.find_by_id(session[:user_id]) : nil
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = User.authenticate!(username, password)
    user ? login_user(user) : redirect('/login')
  end

  get '/logout' do
    session[:user_id] = nil
    redirect '/'
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    logger.info('REGISTER')
    username = params[:username]
    email = params[:email]
    address = params[:address]
    dob = params[:dob]
    fullname = params[:fullname]
    password = params[:password]
    password_confirm = params[:password_confirm]
    begin
      if password == password_confirm
        new_user = User.new(username: username, email: email)
        new_user.password = password
        new_user.dob = dob
        new_user.address = address
        new_user.fullname = fullname
        new_user.save ? login_user(new_user) : fail('Could not create new user')
      else
        fail 'Passwords do not match'
      end
    rescue => e
      logger.error(e)
      redirect '/register'
    end
  end

  get '/' do
    haml :index
  end

  get '/api/v1/credit_card/?' do
    haml :services
  end

  get '/api/v1/credit_card/validate/?' do
    logger.info('VALIDATE')
    begin
      param :card_number, Integer
      fail('Pass a card number') unless params[:card_number]
      card = CreditCard.new(number: "#{params[:card_number]}")
      haml :validated, locals: { number: card.number,
                                 validate_checksum: card.validate_checksum }
    rescue => e
      logger.error(e)
      redirect '/api/v1/credit_card/'
    end

    # { "card": card.number,
    #   "validated": card.validate_checksum
    # }.to_json
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

  get '/api/v1/credit_card/all/?' do
    haml :all, locals: { result: CreditCard.all.map(&:to_s) }
  end
end
