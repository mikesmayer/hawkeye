class AndBackAgain < ActiveRecord::Migration
  def change
  	change_column :p42_tickets, :ticket_open_time, :timestamp
  	change_column :p42_tickets, :ticket_close_time, :timestamp
  end
end
