class CreateP42Tickets < ActiveRecord::Migration
  def change
    create_table :p42_tickets do |t|
      t.float :auto_discount
      t.integer :customer_id
      t.float :gross_price
      t.integer :meal_for_meal
      t.float :manual_discount
      t.float :net_price
      t.datetime :ticket_close_time
      t.datetime :ticket_open_time
      t.integer :pos_ticket_id
      t.integer :customer_phone
      t.float :discount_total

      t.timestamps
    end
  end
end
