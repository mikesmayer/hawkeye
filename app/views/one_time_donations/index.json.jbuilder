json.array!(@one_time_donations) do |one_time_donation|
  json.extract! one_time_donation, :id, :description, :amount, :meals, :deposit_date, :restaurant_id
  json.url one_time_donation_url(one_time_donation, format: :json)
end
