require 'rack/test'
require 'rspec'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    DB[:products].delete
    DB[:users].delete

    DB[:users].insert(username: 'test_user', password_hash: BCrypt::Password.create('test_password'))
  end

  def app
    Rack::Builder.new do
      use Rack::Deflater

      use Rack::Static,
      urls: ["/openapi.yaml"],
      root: ".",
      header_rules: [
        [ %r{openapi\.yaml$}, { "Cache-Control" => "no-cache, no-store, must-revalidate" } ]
      ]

    use Rack::Static,
      urls: ["/AUTHORS"],
      root: ".",
      header_rules: [
        [ %r{AUTHORS$}, { "Cache-Control" => "public, max-age=86400" } ]
      ]

      use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = ->(env) { [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]] }
      end

      run App.new
    end.to_app
  end
end
