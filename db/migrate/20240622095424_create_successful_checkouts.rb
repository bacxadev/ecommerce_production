class CreateSuccessfulCheckouts < ActiveRecord::Migration[6.1]
  def change
    create_table :successful_checkouts do |t|
      t.date :visit_date
      t.string :domain_url
      t.integer :order_id
      t.json :item_id
      t.string :customer_name
      t.string :address

      t.timestamps
    end
  end
end
