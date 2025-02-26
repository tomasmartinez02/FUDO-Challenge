require 'warden'
require 'pry'
require_relative '../models/user'

Warden::Strategies.add(:password) do
  def valid?
    body = request.body.read
    @params = JSON.parse(body) rescue {}

    @params['username'] && @params['password']
  end

  def authenticate!
    user = User.first(username: @params['username'])

    if user && user.authenticate(@params['password'])
      success!(user)
    else
      fail!('Incorrect username or password')
    end
  end
end
