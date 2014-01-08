class CreateP42Tickets < ActiveRecord::Migration
  def change
    create_table :p42_tickets do |t|
      t.integer :pos_ticket_id
      t.float :gross_price
      t.float :net_price
      t.integer :meal_for_meal

      t.timestamps
    end
  end
end
