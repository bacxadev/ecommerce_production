class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.json :data_json

      t.timestamps
    end
  end
end
