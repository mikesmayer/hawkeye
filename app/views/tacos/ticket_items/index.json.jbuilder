json.array!(@tacos_ticket_items) do |tacos_ticket_item|
  json.extract! tacos_ticket_item, :id, :pos_ticket_item_id, :pos_ticket_id, :menu_item_id, :pos_category_id, :pos_revenue_class_id, :quantity, :net_price, :discount_total, :item_menu_price, :ticket_close_time, :meal_for_meal
  json.url tacos_ticket_item_url(tacos_ticket_item, format: :json)
end
