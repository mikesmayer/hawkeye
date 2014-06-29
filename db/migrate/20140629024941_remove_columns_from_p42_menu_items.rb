class RemoveColumnsFromP42MenuItems < ActiveRecord::Migration
  def change
    remove_column :p42_menu_items, :count_meal, :boolean
    remove_column :p42_menu_items, :count_meal_modifier, :integer
  end
end
