json.array!(@p42_ticket_items) do |p42_ticket_item|
  json.extract! p42_ticket_item, :id, :auto_discount, :gross_price, :item_qty, :manual_discount, :menu_itme_group_id, :menu_item_id, :net_price, :pos_ticket_id, :pos_ticket_item_id, :revenue_group_id, :ticket_id, :meal_for_meal
  json.url p42_ticket_item_url(p42_ticket_item, format: :json)
end
