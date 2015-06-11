require 'sinatra'
require 'config_env'
require 'json'
require 'protected_attributes'
require_relative './model/credit_card'
require 'rbnacl/libsodium'
require 'jwt'
require 'openssl'
require 'base64'

# Credit Card API
class CreditCardAPI < Sinatra::Base

  enable :logging

  configure  do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  def authenticate_client_from_header(authorization)
    puts 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    scheme, jwt = authorization.split(' ')
    puts 'HELLOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'
    ui_key = OpenSSL::PKey::RSA.new(Base64.urlsafe_decode64(ENV['UI_PUBLIC_KEY']))
    puts 'HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII'
    payload, header = JWT.decode jwt, ui_key
    puts 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
    @user_id = payload['sub']
    result = (scheme =~ /^Bearer$/i) && (payload['iss'] == 'https://creditcardserviceapp.herokuapp.com')
    return result
  rescue
    false
  end

  get '/' do
    'The Credit Card API is up and running!'
  end

  get '/api/v1/credit_card/validate' do
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
    # halt 401 unless
    puts authenticate_client_from_header(env['HTTP_AUTHORIZATION'])
    request_json = request.body.read
    req = JSON.parse(request_json)
    creditcard = CreditCard.new(
      number: req['number'],
      expiration_date: req['expiration_date'],
      owner: req['owner'],
      credit_network: req['credit_network'],
      user_id: req['user_id']
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


  get '/api/v1/credit_card/:user_id' do
    begin
      creditcards = CreditCard.where(:user_id => params[:user_id]).to_json
    rescue
      halt 500
    end
  end

end
