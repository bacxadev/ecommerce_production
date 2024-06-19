class Traffic < ApplicationRecord
  def self.unique_ip_address_count(date_range)
    where(visit_date: date_range).where.not(ip_address: nil).select(:ip_address).distinct.count
  end
end
