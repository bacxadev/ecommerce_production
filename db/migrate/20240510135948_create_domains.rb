class CreateDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :domains do |t|
      t.date :selected_date
      t.string :domain_name
      t.integer :total_customers
      t.integer :total_order
      t.float :total_revenue, default: 0.0
      t.float :conversion_rate, default: 0.0
      t.integer :total_checkout

      t.timestamps
    end
  end
end
