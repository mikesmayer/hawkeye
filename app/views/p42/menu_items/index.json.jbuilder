json.array!(@p42_menu_items) do |p42_menu_item|
  json.extract! p42_menu_item, :id, :gross_price, :menu_item_group_id, :name, :recipe_id, :revenue_group_id, :count_meal, :count_meal_start, :count_meal_end, :count_meal_modifier
  json.url p42_menu_item_url(p42_menu_item, format: :json)
end
