json.array!(@p42_menu_item_groups) do |p42_menu_item_group|
  json.extract! p42_menu_item_group, :id, :name, :default_meal_modifier
  json.url p42_menu_item_group_url(p42_menu_item_group, format: :json)
end
