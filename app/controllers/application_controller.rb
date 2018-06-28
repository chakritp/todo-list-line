class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  
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
