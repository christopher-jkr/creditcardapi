require 'base64'
require 'rbnacl/libsodium'
require 'jwt'
require 'pony'

# Helper module for CreditCardAPI class
module CreditCardHelper
  def login_user(user)
    payload = { user_id: user.id }
    token = JWT.encode payload, ENV['MSG_KEY'], 'HS256'
    session[:auth_token] = token
    redirect '/'
  end

  def find_user_by_token(token)
    return nil unless token
    decoded_token = JWT.decode token, ENV['MSG_KEY'], true
    payload = decoded_token.first
    logger.info "PAYLOAD: #{payload}"
    User.find_by_id(payload['user_id'])
  end

  # Handling user registration
  class Registration
    attr_accessor :username, :password, :email, :dob, :address, :fullname

    def initialize(user_data)
      user_data.each do |k, _|
        instance_variable_set("@#{k}", user_data[k])
      end
    end

    def complete?
      list = instance_variables.map { |var| instance_variable_get var }
      list.all? do |var|
        var && var.length > 0
      end
    end
  end

  def email_registration_verification(registration)
    payload = { username: registration.username, email: registration.email,
                password: registration.password, dob: registration.dob,
                address: registration.address, fullname: registration.fullname }
    token = JWT.encode payload, ENV['MSG_KEY'], 'HS256'
    enc_msg = encrypt_message(token)
    Pony.mail(to: registration.email,
              subject: 'Your CreditCardAPI Account is Ready.',
              html_body: registration_email(enc_msg))
  end

  def registration_email(enc_msg)
    verification_url = "#{request.base_url}/register?token=#{enc_msg}"
    '<H1>CreditCardAPI Registration Received</H1>'\
    "<p>Please <a href=\"#{verification_url}\">click here</a> to validate "\
    'your email and activate your account.</p>'
  end

  def encrypt_message(token)
    key = Base64.urlsafe_decode64(ENV['MSG_KEY'])
    secret_box = RbNaCl::SecretBox.new(key)
    nonce = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
    nonce_s = Base64.urlsafe_encode64(nonce)
    enc_token = Base64.urlsafe_encode64(secret_box.encrypt(nonce, token))
    Base64.urlsafe_encode64({ 'message' => enc_token,
                              'nonce' => nonce_s }.to_json)
  end

  def decrypt_message(enc_msg)
    key = Base64.urlsafe_decode64(ENV['MSG_KEY'])
    secret_box = RbNaCl::SecretBox.new(key)
    msg_json = JSON.parse(Base64.urlsafe_decode64(enc_msg))
    nonce = Base64.urlsafe_decode64(msg_json['nonce'])
    msg = Base64.urlsafe_decode64(msg_json['message'])
    secret_box.decrypt(nonce, msg)
  rescue
    raise 'INVALID ENCRYPTED MESSAGE'
  end

  def create_account_with_registration(registration)
    new_user = User.new(username: registration.username,
                        email: registration.email)
    new_user.password = registration.password
    new_user.dob = registration.dob
    new_user.address = registration.address
    new_user.fullname = registration.fullname
    new_user.save ? login_user(new_user) : fail('Could not create new user')
  end

  def create_account_with_enc_token(enc_msg)
    token = decrypt_message(enc_msg)
    payload = (JWT.decode token, ENV['MSG_KEY']).first
    reg = Registration.new(payload)
    create_account_with_registration(reg)
  end
end
