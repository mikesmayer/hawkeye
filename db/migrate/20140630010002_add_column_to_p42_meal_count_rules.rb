class AddColumnToP42MealCountRules < ActiveRecord::Migration
  def change
    add_column :p42_meal_count_rules, :start_date, :date
    add_column :p42_meal_count_rules, :end_date, :date
  end
end
