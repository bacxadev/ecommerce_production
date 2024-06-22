class Traffic < ApplicationRecord
  def self.unique_ip_address_count(date_range)
    where(visit_date: date_range).select(:ip_address).distinct.count
  end

  def self.total_views(date_range)
    where(visit_date: date_range).count
  end
end
