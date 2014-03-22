class RemoveCountMealEndFromP42MenuItems < ActiveRecord::Migration
  def change
    remove_column :p42_menu_items, :count_meal_end, :time
  end
end
