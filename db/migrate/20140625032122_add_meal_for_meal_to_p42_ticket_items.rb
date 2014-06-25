class AddMealForMealToP42TicketItems < ActiveRecord::Migration
  def change
    add_column :p42_ticket_items, :meal_for_meal, :float
  end
end
