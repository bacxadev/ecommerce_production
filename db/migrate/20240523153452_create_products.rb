class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :domain
      t.integer :product_id

      t.timestamps
    end
  end
end
