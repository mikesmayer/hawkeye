class AddDefaultValuesToP42MealCountRules < ActiveRecord::Migration
  def change
  	change_column :p42_meal_count_rules, :start_date, :date, :default => '2000-01-01'
  	change_column :p42_meal_count_rules, :end_date, :date, :default => '2100-01-01'
  end
end
