class FixColumnName < ActiveRecord::Migration
  def change
  	rename_column :p42_meal_count_rules, :p42_menu_item_id, :menu_item_id
  end
end
