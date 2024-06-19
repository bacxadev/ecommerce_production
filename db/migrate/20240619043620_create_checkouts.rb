class CreateCheckouts < ActiveRecord::Migration[6.1]
  def change
    create_table :checkouts do |t|
      t.date :visit_date
      t.string :ip_address
      t.string :product_id
      t.string :domain_url
      t.string :item_id
      t.string :order_id
      t.string :total

      t.timestamps
    end
  end
end
