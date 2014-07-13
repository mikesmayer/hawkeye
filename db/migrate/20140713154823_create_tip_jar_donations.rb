class CreateTipJarDonations < ActiveRecord::Migration
  def change
    create_table :tip_jar_donations do |t|
      t.float :amount
      t.float :meals
      t.date :deposit_date
      t.integer :restaurant_id

      t.timestamps
    end
  end
end
