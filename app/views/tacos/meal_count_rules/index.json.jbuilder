json.array!(@tacos_meal_count_rules) do |tacos_meal_count_rule|
  json.extract! tacos_meal_count_rule, :id, :menu_item_id, :meal_modifier, :start_date, :end_date
  json.url tacos_meal_count_rule_url(tacos_meal_count_rule, format: :json)
end
