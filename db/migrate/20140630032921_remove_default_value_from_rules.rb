class RemoveDefaultValueFromRules < ActiveRecord::Migration
  def change
  	change_column_default(:p42_meal_count_rules, :start_date, nil)
  	change_column_default(:p42_meal_count_rules, :end_date, nil)

  end
end
