require_relative '../config/database'
require 'sequel'
require 'securerandom'

class Product < Sequel::Model(:products)
  plugin :timestamps, update_on_create: true

  def validate
    super
    errors.add(:name, "is required") if name.nil? || name.strip.empty?
  end
end
