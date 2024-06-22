class CreateCheckouts < ActiveRecord::Migration[6.1]
  def change
    create_table :checkouts do |t|
      t.date :visit_date
      t.string :ip_address
      t.string :domain

      t.timestamps
    end
  end
end
