json.array!(@p42_discount_items) do |p42_discount_item|
  json.extract! p42_discount_item, :id, :auto_apply, :discount_amount, :discount_item_id, :menu_item_id, :pos_ticket_id, :pos_ticket_item_id, :reason_text, :ticket_id, :ticket_item_id, :ticket_item_price, :when
  json.url p42_discount_item_url(p42_discount_item, format: :json)
end
