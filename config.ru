require_relative 'app'
require_relative 'config/warden'
require_relative 'config/logging'
require 'pry'
require 'logger'
require 'dotenv'

Dotenv.load

use Rack::CommonLogger, LOGGER

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

map "/auth" do
  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = ->(env) { [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]] }
  end

  run App.new
end

run App.new
