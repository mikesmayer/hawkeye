class AddDobToTacosTicketItems < ActiveRecord::Migration
  def change
    add_column :tacos_ticket_items, :DOB, :date
  end
end
