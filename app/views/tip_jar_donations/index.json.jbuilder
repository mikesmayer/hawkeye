json.array!(@tip_jar_donations) do |tip_jar_donation|
  json.extract! tip_jar_donation, :id, :amount, :meals, :deposit_date, :restaurant_id
  json.url tip_jar_donation_url(tip_jar_donation, format: :json)
end
