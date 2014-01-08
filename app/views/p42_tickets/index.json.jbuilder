json.array!(@p42_tickets) do |p42_ticket|
  json.extract! p42_ticket, :id, :pos_ticket_id, :gross_price, :net_price, :meal_for_meal
  json.url p42_ticket_url(p42_ticket, format: :json)
end
