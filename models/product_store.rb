require 'thread'
require_relative 'product'
require_relative '../config/logging'

class ProductStore
  def initialize
    @queue = Queue.new
    @worker_count = ENV.fetch('PRODUCT_WORKERS', 2).to_i
    start_workers
  end

  def create_product(name)
    enqueue_time = Time.now + 5
    @queue << { name: name, process_at: enqueue_time }
  end

  private

  def start_workers
    @worker_count.times do |i|
      Thread.new do
        loop do
          params = @queue.pop
          wait_time = params[:process_at] - Time.now

          if wait_time > 0
            sleep wait_time
          end

          product = Product.create(name: params[:name])
          LOGGER.info "[Worker #{i}]: Product created successfully: #{product.values}"
        end
      end
    end
  end
end

PRODUCT_STORE = ProductStore.new
