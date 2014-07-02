class ChangeColumnsP42MealCountRules < ActiveRecord::Migration
  def change
  	remove_column :p42_meal_count_rules, :start_date, :date
  	remove_column :p42_meal_count_rules, :end_date, :date
  end
end
