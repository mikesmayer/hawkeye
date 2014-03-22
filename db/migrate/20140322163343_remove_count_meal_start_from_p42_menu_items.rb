class RemoveCountMealStartFromP42MenuItems < ActiveRecord::Migration
  def change
    remove_column :p42_menu_items, :count_meal_start, :time
  end
end
