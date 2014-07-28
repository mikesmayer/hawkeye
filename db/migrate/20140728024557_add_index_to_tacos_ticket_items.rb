class AddIndexToTacosTicketItems < ActiveRecord::Migration
  def change
  		add_index :tacos_ticket_items, :pos_ticket_item_id
  end
end
