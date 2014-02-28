class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.integer :bek_customer_number
      t.string :soap_url
      t.string :soap_endpoint

      t.timestamps
    end
  end
end
