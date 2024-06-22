class AddToCart < ApplicationRecord
  def self.total_add_to_cart(date_range)
    where(visit_date: date_range).count
  end
end
