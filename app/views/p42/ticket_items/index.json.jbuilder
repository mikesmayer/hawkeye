json.array!(@p42_ticket_items) do |p42_ticket_item|
  json.extract! p42_ticket_item, :id, :ticket_item_id, :ticket_id, :menu_item_id, :category_id, :revenue_class_id, :customer_original_id, :quantity, :net_price, :discount_total, :item_menu_price, :choice_additions_total, :ticket_close_time
  json.url p42_ticket_item_url(p42_ticket_item, format: :json)
end
