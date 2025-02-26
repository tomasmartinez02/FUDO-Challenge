require 'thread'
require_relative 'product'

class ProductStore
  def initialize
    @queue = Queue.new
    start_worker
  end

  def create_product(name)
    @queue << { name: name }
  end

  private

  def start_worker
    Thread.new do
      loop do
        params = @queue.pop
        product = Product.create(name: params[:name])
        puts "Product created succesfully: #{product.values}"
      end
    end
  end
end

PRODUCT_STORE = ProductStore.new
