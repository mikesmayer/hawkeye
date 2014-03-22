json.array!(@p42_meal_count_rules) do |p42_meal_count_rule|
  json.extract! p42_meal_count_rule, :id, :p42_menu_item_id, :start_date, :end_date, :meal_modifier
  json.url p42_meal_count_rule_url(p42_meal_count_rule, format: :json)
end
