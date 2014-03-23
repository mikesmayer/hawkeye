class FixTicketItemColumnName < ActiveRecord::Migration
  def change
  	rename_column :p42_ticket_items, :menu_itme_group_id, :menu_item_group_id
  end
end
