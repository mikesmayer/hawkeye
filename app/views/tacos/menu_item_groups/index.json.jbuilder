json.array!(@tacos_menu_item_groups) do |tacos_menu_item_group|
  json.extract! tacos_menu_item_group, :id, :name, :default_meal_modifier
  json.url tacos_menu_item_group_url(tacos_menu_item_group, format: :json)
end
