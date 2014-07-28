class CreateTacosTicketItems < ActiveRecord::Migration
  def change
    create_table :tacos_ticket_items do |t|
      t.integer :pos_ticket_item_id
      t.integer :pos_ticket_id
      t.integer :menu_item_id
      t.integer :pos_category_id
      t.integer :pos_revenue_class_id
      t.float :quantity
      t.float :net_price
      t.float :discount_total
      t.float :item_menu_price
      t.datetime :ticket_close_time
      t.float :meal_for_meal

      t.timestamps
    end
  end
end
