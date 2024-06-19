class CreateTraffics < ActiveRecord::Migration[6.1]
  def change
    create_table :traffics do |t|
      t.date :visit_date
      t.string :ip_address
      t.string :product_id
      t.string :domain_url

      t.timestamps
    end
  end
end
