class CreateP42DiscountItems < ActiveRecord::Migration
  def change
    create_table :p42_discount_items do |t|
      t.boolean :auto_apply
      t.float :discount_amount
      t.integer :discount_item_id
      t.integer :menu_item_id
      t.integer :pos_ticket_id
      t.integer :pos_ticket_item_id
      t.string :reason_text
      t.integer :ticket_id
      t.integer :ticket_item_id
      t.float :ticket_item_price
      t.time :when

      t.timestamps
    end
  end
end
