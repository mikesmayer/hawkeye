class CreateP42TicketItems < ActiveRecord::Migration
  def change
    create_table :p42_ticket_items do |t|
      t.float :auto_discount
      t.float :gross_price
      t.integer :item_qty
      t.float :manual_discount
      t.integer :menu_itme_group_id
      t.integer :menu_item_id
      t.float :net_price
      t.integer :pos_ticket_id
      t.integer :pos_ticket_item_id
      t.integer :revenue_group_id
      t.integer :ticket_id
      t.integer :meal_for_meal

      t.timestamps
    end
  end
end
