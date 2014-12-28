class CreateOneTimeDonations < ActiveRecord::Migration
  def change
    create_table :one_time_donations do |t|
      t.string :description
      t.float :amount
      t.float :meals
      t.date :deposit_date
      t.integer :restaurant_id

      t.timestamps
    end
  end
end
