class RenameDobToDobTacosTicketItems < ActiveRecord::Migration
  def change
  	rename_column :tacos_ticket_items, :DOB, :dob
  end
end
