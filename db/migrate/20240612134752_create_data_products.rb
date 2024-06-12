class CreateDataProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :data_products do |t|
      t.integer :product_id
      t.string :product_title
      t.string :product_link
      t.string :domain_url

      t.timestamps
    end
  end
end
