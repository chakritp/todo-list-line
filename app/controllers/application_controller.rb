require 'line/bot'

class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :client
  

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
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
