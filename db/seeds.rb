require_relative '../models/user'

if User.count == 0
  User.create(username: 'admin', password: 'password123')
  User.create(username: 'user1', password: 'secret')
end
