class Domain < ApplicationRecord
  has_many :products

  def total_order_count
    products.sum(:order_count)
  end

  def sum_revenue_by_products
    products.sum(:revenue)
  end

  def self.run_service
    CleanSheetService.new().execute
  end
end
