class CreateAddToCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :add_to_carts do |t|
      t.date :visit_date
      t.string :ip_address
      t.string :product_id
      t.string :domain_url
      t.string :add_to_cart

      t.timestamps
    end
  end
end
