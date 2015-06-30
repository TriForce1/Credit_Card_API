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
require 'rack/ssl-enforcer'
require 'rdiscount'
require 'tilt/rdiscount'
require 'dalli'
require 'active_support'
require 'active_support/core_ext'

# Credit Card API
configure  :develpoment, :test, :production do
  require 'config_env'
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end


class CreditCardAPI < Sinatra::Base

  enable :logging

  configure  do
    Hirb.enable
    set :cards_cache, Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "").split(","),
     {:username => ENV["MEMCACHIER_USERNAME"],
       :password => ENV["MEMCACHIER_PASSWORD"],
       :socket_timeout => 1.5,
       :socket_failure_delay => 0.2
       })
  end

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  def authenticate_client_from_header(authorization)
    scheme, jwt = authorization.split(' ')
    ui_key = OpenSSL::PKey::RSA.new(Base64.urlsafe_decode64(ENV['UI_PUBLIC_KEY']))
    payload, header = JWT.decode jwt, ui_key
    @user_id = payload['sub']
    result = (scheme =~ /^Bearer$/i) && (payload['iss'] == 'https://creditcardserviceapp.herokuapp.com')
    return result
  rescue
    false
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
      user_id: @user_id
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
    halt 401 unless @params[:user_id] == @user_id.to_s
    begin
      cards = card_index
      print cards
    rescue
      halt 500
    end
    cards.to_json
  end

  def card_index
    begin
      creditcards = CreditCard.where("user_id = ?", @user_id)
      card_list = get_card_number(creditcards)
      c_index = {user_id: @user_id, cards: card_list }
    rescue
      halt 309
      settings.cards_cache.set(@user_id, c_index.to_json)
      c_index
    end
  end

  def get_card_number(creditcards)
    c_list = creditcards.map(){ |x|
      secret_box = RbNaCl::SecretBox.new(key)
      {number: ("*"*12) + secret_box.decrypt(Base64.decode64(x[:nonce]), Base64.decode64(x[:encrypted_number])).split(//).last(4).join,
      owner: x.owner,
      date: x.created_at,
      network: x.credit_network,
      expiration: x.expiration_date
      }}    
    c_list
  end

end
