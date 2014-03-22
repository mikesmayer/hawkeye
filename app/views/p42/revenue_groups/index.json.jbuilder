json.array!(@p42_revenue_groups) do |p42_revenue_group|
  json.extract! p42_revenue_group, :id, :name
  json.url p42_revenue_group_url(p42_revenue_group, format: :json)
end
