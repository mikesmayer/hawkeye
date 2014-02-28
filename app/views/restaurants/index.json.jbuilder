json.array!(@restaurants) do |restaurant|
  json.extract! restaurant, :id, :name, :bek_customer_number, :soap_url, :soap_endpoint
  json.url restaurant_url(restaurant, format: :json)
end
