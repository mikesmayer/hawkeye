json.array!(@p42_tickets) do |p42_ticket|
  json.extract! p42_ticket, :id, :auto_discount, :customer_id, :gross_price, :meal_for_meal, :manual_discount, :net_price, :ticket_close_time, :ticket_open_time, :pos_ticket_id, :customer_phone, :discount_total
  json.url p42_ticket_url(p42_ticket, format: :json)
end
