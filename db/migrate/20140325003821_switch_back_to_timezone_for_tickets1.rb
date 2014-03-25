class SwitchBackToTimezoneForTickets1 < ActiveRecord::Migration
  def change
  	change_column :p42_tickets, :ticket_open_time, 'timestamp with time zone'
  	change_column :p42_tickets, :ticket_close_time, 'timestamp with time zone'
  end
end
