class ChangeMealModifierForP42MealCountRules < ActiveRecord::Migration
  def change
  	change_column :p42_meal_count_rules, :meal_modifier, :float
  end
end
