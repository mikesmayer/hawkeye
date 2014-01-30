class DropP42Tickets < ActiveRecord::Migration
  def change
  	drop_table :p42_tickets
  end
end
