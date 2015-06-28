require 'sinatra'
require 'hirb'
require 'json'
require 'protected_attributes'
require_relative './model/credit_card'
require 'rbnacl/libsodium'
require 'jwt'
require 'openssl'
require 'base64'
require 'sinatra/activerecord'

# Credit Card API
configure  :develpoment, :test, :production do
  require 'config_env'
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end


class CreditCardAPI < Sinatra::Base

  enable :logging

  configure  do
    Hirb.enable
  end

  def authenticate_client_from_header(authorization)
    scheme, jwt = authorization.split(' ')
    ui_key = OpenSSL::PKey::RSA.new(Base64.urlsafe_decode64(ENV['UI_PUBLIC_KEY']))
    payload, header = JWT.decode jwt, ui_key
    @user_id = payload['sub']
    result = (scheme =~ /^Bearer$/i) && (payload['iss'] == 'http://creditcardserviceapp.herokuapp.com')
    return result
  rescue
    false
  end

  def get_card_number(creditcards)
    creditcards.each { |x|
      secret_box = RbNaCl::SecretBox.new(key)
       x[:encrypted_number] = secret_box.decrypt(Base64.decode64(x[:nonce]), Base64.decode64(x[:encrypted_number]))}.to_json
  end

  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
  end

  get '/' do
    'The Credit Card API is up and running!'
  end

  get '/api/v1/credit_card/validate' do
    content_type :json
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    c = CreditCard.new(
      number: params[:card_number]
    )

    # Method to convert string to integer
    # Returns false if string is not only digits
    result = Integer(params[:card_number]) rescue false

    # Validate for string length and correct type
    if result == false || params[:card_number].length < 2
      return { "Card" => params[:card_number], "validated" => "false" }.to_json
    end

    {"Card" => params[:card_number], "validated" => c.validate_checksum}.to_json
  end

  post '/api/v1/credit_card' do
    content_type :json
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    request_json = request.body.read
    req = JSON.parse(request_json)
    creditcard = CreditCard.new(
      number: req['number'],
      expiration_date: req['expiration_date'],
      owner: req['owner'],
      credit_network: req['credit_network'],
      user_id: params['user_id']
    )

    begin
      unless creditcard.validate_checksum
        halt 400
      else
        creditcard.save
        status 201
      end
    rescue
      halt 410
    end
  end

  get '/api/v1/credit_card' do
    content_type :json
    halt 401 unless authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    begin
      creditcards = CreditCard.where("user_id = ?", params[:user_id])
      get_card_number(creditcards)
    rescue
      halt 500
    end
  end

end
