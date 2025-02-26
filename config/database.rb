require 'sequel'

DB = Sequel.connect('sqlite://db/development.db')

DB.create_table? :products do
  primary_key :id
  String :name, null: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

DB.create_table? :users do
  primary_key :id
  String :username, null: false, unique: true
  String :password_hash, null: false
end
