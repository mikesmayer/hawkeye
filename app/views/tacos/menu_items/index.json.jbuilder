json.array!(@tacos_menu_items) do |tacos_menu_item|
  json.extract! tacos_menu_item, :id, :menu_item_group_id, :name, :recipe_id
  json.url tacos_menu_item_url(tacos_menu_item, format: :json)
end
