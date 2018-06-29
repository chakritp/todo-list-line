require 'line/bot'
require 'net/https'
require 'open-uri'
require 'jwt'

class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :client
  

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def auth
    code = params["code"]

    payload = {
      grant_type: 'authorization_code',
      code: code, # wyN0w0oiQtwxqEPNJrjW
      redirect_uri: 'https://7088a30f.ngrok.io/auth',
      client_id: ENV['LINE_CHANNEL_ID'],
      client_secret: ENV['LINE_LOGIN_CHANNEL_SECRET']
    }

    uri = URI.parse("https://api.line.me/oauth2/v2.1/token")

    header = {'Content-Type' => 'application/x-www-form-urlencoded'}
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.request_uri, header)
    query = URI.encode_www_form(payload)
    # request.body = query
    # puts request.body.inspect
    response = http.request(request, query)

    puts response.body.inspect
    response_body = JSON.parse(response.body)

    # save info to user model
    access_token = response_body['access_token']
    token_type = response_body['token_type']
    id_token = response_body['id_token']

    decoded_id_token = JWT.decode(id_token, ENV['LINE_LOGIN_CHANNEL_SECRET'], { audience: ENV['LINE_CHANNEL_ID'], issuer: 'https://access.line.me', algorithms: ['HS256'] })
    puts decoded_id_token.inspect

    line_id = decoded_id_token[0]['sub']
    name = decoded_id_token[0]['sub']
    picture = decoded_id_token[0]['picture']

    get_user(line_id)
    @user.update_columns(name: name)
    
    redirect_to todo_items_path(@user.id)
  end

  def get_user(user_id)
    begin
      @user = User.find_or_create_by(line_id: user_id)
    rescue ActiveRecord::RecordNotUnique
      @user = User.find_by(line_id: user_id)
    end
  end
  
  private

  def verify_signature
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, ENV["LINE_CHANNEL_SECRET"], http_request_body)
    signature = Base64.strict_encode64(hash)

    unless signature == request.headers["HTTP_X_LINE_SIGNATURE"]
      render json: {
        text: "Bad Request",
        status: 400
      }
    end
  end
end
