require 'rack'
require 'json'
require_relative 'config/warden'
require_relative 'config/jwt_auth'
require_relative 'models/product_store'
require 'pry'
require './config/database'
require './models/user'

class App
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    if req.path != '/auth'
      user = authenticate_request(req, res)
      return res.finish if user.nil?
    end

    case [req.request_method, req.path]
    when ['POST', '/auth']
      handle_auth(res, env)

    when ['POST', '/products']
      handle_create_product(req, res)

    when ['GET', '/products']
      handle_list_products(req, res)

    when ->(method_path) { method_path[0] == 'GET' && method_path[1] =~ %r{^/products/(\d+)$} }
      handle_get_product(req, res)

    else
      handle_not_found(res)
    end

    res.finish
  end

  private

  def handle_not_found(res)
    res.status = 404
    res['Content-Type'] = 'application/json'
    res.write({ error: 'Not Found' }.to_json)
  end

  def handle_auth(res, env)
    env['warden'].authenticate!
    user = env['warden'].user

    token = JWTAuth.encode({ username: user.username })
    res.status = 200
    res['Content-Type'] = 'application/json'
    res.write({ token: token, message: "Authenticated as #{user.username}" }.to_json)
  end

  def authenticate_request(req, res)
    token = req.get_header('HTTP_AUTHORIZATION')&.split(' ')&.last
    decoded = JWTAuth.decode(token)

    if decoded
      decoded
    else
      res.status = 401
      res['Content-Type'] = 'application/json'
      res.write({ error: 'Invalid or expired token' }.to_json)
      nil
    end
  end

  def handle_create_product(req, res)
    body = JSON.parse(req.body.read) rescue {}
    PRODUCT_STORE.create_product(body['name'])
    res.status = 202
    res['Content-Type'] = 'application/json'
    res.write({ message: 'Product creation in progress'}.to_json)
  end

  def handle_list_products(req, res)
    res.status = 200
    res['Content-Type'] = 'application/json'
    res.write(Product.all.map(&:values).to_json)
  end

  def handle_get_product(req, res)
    product_id = req.path.split('/').last
    product = Product[product_id]

    if product
      res.status = 200
      res['Content-Type'] = 'application/json'
      res.write(product.values.to_json)
    else
      res.status = 404
      res.write({ error: 'Product not found' }.to_json)
    end
  end
end
