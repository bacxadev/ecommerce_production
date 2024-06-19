class Product < ApplicationRecord
  def self.total_visitor(date_range)
    where(visit_date: date_range).where.not(order_id: "0").count
  end
end
