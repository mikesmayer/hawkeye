class CreateP42MealCountRules < ActiveRecord::Migration
  def change
    create_table :p42_meal_count_rules do |t|
      t.integer :p42_menu_item_id
      t.time :start_date
      t.time :end_date
      t.integer :meal_modifier

      t.timestamps
    end
  end
end
