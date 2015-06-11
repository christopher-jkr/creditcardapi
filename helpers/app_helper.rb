require 'jwt'

# App Helper
module AppHelper
  def authenticate_client_from_header(authorization)
    scheme, jwt = authorization.split(' ')
    ui_key = OpenSSL::PKey::RSA.new(ENV['UI_PUBLIC_KEY'])
    payload, _header = JWT.decode jwt, ui_key
    @user_id = payload['sub']
    (scheme =~ /^Bearer$/i) && (payload['iss'] == 'https://appropriate-credit1card2api3.herokuapp.com/')
  rescue
    false
  end
end
