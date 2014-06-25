class FixColumnNames < ActiveRecord::Migration
  def change
  	change_table :p42_ticket_items do |t|
  		t.rename :ticket_item_id, :pos_ticket_item_id
  		t.rename :ticket_id, :pos_ticket_id
  		t.rename :category_id, :pos_category_id
  		t.rename :revenue_class_id, :pos_revenue_class_id
  	end
  end
end
