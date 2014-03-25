class AddTicketCloseTimeStringToP42Tickets < ActiveRecord::Migration
  def change
    add_column :p42_tickets, :ticket_close_time_string, :string
  end
end
