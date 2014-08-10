class P42::RevenueGroup < ActiveRecord::Base
	has_many :menu_items

	def self.sync_revenue_groups
		initialize_soap

		rev_groups_response = get_revenue_groups

		rev_groups_response.each do |revenue_group|
			id = revenue_group[:id]
			name = revenue_group[:description]		

			P42::RevenueGroup.find_or_update_by_id(id, name)
		end
		return "Sync completed successfully"
	end


	private
	def self.initialize_soap
		@client = Savon.client(wsdl: Restaurant.find(1).soap_url, endpoint: Restaurant.find(1).soap_endpoint)
	end

	def self.get_revenue_groups
		response = @client.call(:get_all_revenue_classes)
		response.body[:get_all_revenue_classes_response][:get_all_revenue_classes_result][:revenue_class]
	end

	def self.find_or_update_by_id(id, name)
		results = { :action => '', :obj_id => nil, :error => nil }

		revenue_group = P42::RevenueGroup.find_by_id(id)
		if revenue_group.nil?
			revenue_group = P42::RevenueGroup.create(:id => id, :name => name)
			
			if revenue_group.errors.count > 0 
				results[:error] = "Failed to create p42 revenue group."
			else  
				results[:action] = "create"
			end
		else
			unless revenue_group.update_attributes(:name => name)
				results[:error] = "Failed to update p42 revenue class #{revenue_group.id}"
			end
			results[:action] = "update"
		end
		results[:obj_id] = revenue_group.id
		results
	end
end
