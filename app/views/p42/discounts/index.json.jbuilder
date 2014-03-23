json.array!(@p42_discounts) do |p42_discount|
  json.extract! p42_discount, :id, :active, :name
  json.url p42_discount_url(p42_discount, format: :json)
end
