class CreateP42TicketItems < ActiveRecord::Migration
  def change
    create_table :p42_ticket_items do |t|
      t.integer :ticket_item_id
      t.integer :ticket_id
      t.integer :menu_item_id
      t.integer :category_id
      t.integer :revenue_class_id
      t.integer :customer_original_id
      t.float :quantity
      t.float :net_price
      t.float :discount_total
      t.float :item_menu_price
      t.float :choice_additions_total
      t.datetime :ticket_close_time

      t.timestamps
    end
    add_index :p42_ticket_items, [:ticket_item_id], :unique => true
  end
end
