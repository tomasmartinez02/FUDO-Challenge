require 'jwt'

module JWTAuth
  SECRET_KEY = 'super_secret_key'

  def self.encode(payload, exp = 3600)
    payload[:exp] = Time.now.to_i + exp
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    decoded if decoded['exp'] >= Time.now.to_i
  rescue
    nil
  end
end
