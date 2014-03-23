class ChangeCustomerPhoneDataTypeInTickets < ActiveRecord::Migration
  def change
  	change_column :p42_tickets, :customer_phone, :string
  end
end
