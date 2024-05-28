class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.date :selected_date
      t.string :product_name
      t.integer :visitor
      t.integer :order_count
      t.float :cr, default: 0.0
      t.float :revenue, default: 0.0
      t.references :domain

      t.timestamps
    end
  end
end
