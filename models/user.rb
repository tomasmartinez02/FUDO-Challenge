require_relative '../config/database'
require 'bcrypt'

class User < Sequel::Model(:users)
  plugin :timestamps, update_on_create: true

  def password=(new_password)
    self.password_hash = BCrypt::Password.create(new_password)
  end

  def authenticate(password)
    BCrypt::Password.new(password_hash) == password
  end
end
