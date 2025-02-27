require 'sequel'

DB = Sequel.connect(ENV['RACK_ENV'] == 'test' ? 'sqlite://db/test.sqlite3' : 'sqlite://db/development.sqlite3')

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
