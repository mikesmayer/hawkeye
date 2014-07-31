class AddVoidColumnToTacosTicketItems < ActiveRecord::Migration
  def change
    add_column :tacos_ticket_items, :void, :boolean
  end
end
