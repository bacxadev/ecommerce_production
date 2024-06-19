class Checkout < ApplicationRecord
  def self.sum_total_where_order_id_not_zero(date_range)
    where(visit_date: date_range).where.not(order_id: "0").sum(:total)
  end

  def self.total_checkout(date_range)
    all_ip_addresses = where(visit_date: date_range).pluck(:ip_address).uniq
    all_ip_addresses.count
  end

  def self.total_order(date_range)
    where(visit_date: date_range).where.not(order_id: "0").count
  end
end
