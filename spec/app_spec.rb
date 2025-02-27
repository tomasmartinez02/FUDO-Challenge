require 'spec_helper'

RSpec.describe 'App API' do
  include Rack::Test::Methods

  let(:auth_token) do
    post '/auth', { username: 'test_user', password: 'test_password' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(last_response.body)['token']
  end

  describe 'POST /auth' do
    it 'returns 401 incorrect password' do
      post '/auth', { username: 'test_user', password: 'wrong_password' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(401)
      expect(JSON.parse(last_response.body)).to include('error' => 'Unauthorized')
    end

    it 'authenticates a user and returns a token' do
      post '/auth', { username: 'test_user', password: 'test_password' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to have_key('token')
    end
  end

  describe 'POST /products' do
    it 'queues a product creation request' do
      header 'Authorization', "Bearer #{auth_token}"
      post '/products', { name: 'Laptop' }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(202)
      expect(JSON.parse(last_response.body)).to eq({ 'message' => 'Product creation in progress' })
    end
  end

  describe 'GET /products - delayed availability' do
    it 'does not list the product within 5 seconds and lists it after' do
      header 'Authorization', "Bearer #{auth_token}"

      post '/products', { name: 'Delayed Product' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(202)

      sleep 2
      get '/products'
      expect(last_response.status).to eq(200)

      products_before = JSON.parse(last_response.body)
      product_names_before = products_before.map { |p| p['name'] }

      expect(product_names_before).not_to include('Delayed Product')

      sleep 5
      get '/products'
      expect(last_response.status).to eq(200)

      products_after = JSON.parse(last_response.body)
      product_names_after = products_after.map { |p| p['name'] }

      expect(product_names_after).to include('Delayed Product')
    end
  end

  describe 'GET /products - when no token is provided' do
    it 'returns a 401 Unauthorized' do
      get '/products'

      expect(last_response.status).to eq(401), "Expected 200 but got #{last_response.status}"
      expect(JSON.parse(last_response.body)).to eq({"error" => "Unauthorized"})
    end
  end

  describe 'Responses with Gzip compression' do
    it 'returns a compressed response when requested' do
      header 'Authorization', "Bearer #{auth_token}"
      header 'Accept-Encoding', 'gzip'

      get '/products'
      expect(last_response.status).to eq(200)

      expect(last_response.headers['Content-Encoding']).to eq('gzip')
    end
  end

  describe 'Static file routes' do
    it 'serves the AUTHORS file' do
      get '/AUTHORS'

      expect(last_response.status).to eq(200), "Expected 200 but got #{last_response.status}"
      expect(last_response.headers['Cache-Control']).to eq('public, max-age=86400')
      expect(last_response.body).to include('Tomas Martinez')
    end

    it 'serves the OpenAPI specification file' do
      get '/openapi.yaml'

      expect(last_response.status).to eq(200), "Expected 200 but got #{last_response.status}"
      expect(last_response.headers['Cache-Control']).to eq('no-cache, no-store, must-revalidate')
      expect(last_response.body).to include('openapi')
    end

    it 'serves the OpenAPI specification file compressed with gzip when requested' do
      header 'Accept-Encoding', 'gzip'
      get '/openapi.yaml'

      expect(last_response.status).to eq(200), "Expected 200 but got #{last_response.status}"
      expect(last_response.headers['Content-Encoding']).to eq('gzip'), "Expected gzip but got #{last_response.headers['Content-Encoding'].inspect}"
    end
  end

end
