class CreateManageProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :manage_products do |t|
      t.date :visit_date
      t.string :ip_address
      t.integer :product_id
      t.string :domain_url
      t.string :add_to_cart
      t.string :order_id
      t.json :order_detail
      t.boolean :checkout

      t.timestamps
    end
  end
end
