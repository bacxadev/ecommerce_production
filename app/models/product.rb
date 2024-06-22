class Product < ApplicationRecord
  def self.total_visitor(date_range)
    where(visit_date: date_range).count
  end
end
