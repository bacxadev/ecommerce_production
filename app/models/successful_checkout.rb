class SuccessfulCheckout < ApplicationRecord
  def self.total_revenue(date_range)
    total_sum = 0

    self.where(visit_date: date_range).find_in_batches(batch_size: 1000) do |group|
      group.each do |checkout|
        items = JSON.parse(checkout.item_id)
        items.each do |item|
          total_sum += item['total'].to_f
        end
      end
    end

    total_sum
  end
end
