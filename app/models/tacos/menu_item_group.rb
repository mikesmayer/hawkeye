class Tacos::MenuItemGroup < ActiveRecord::Base
	has_many :menu_items



	def self.find_or_update_by_id(id, name)
  		results = { :action => '', :obj => nil, :error => nil }
		category = Tacos::MenuItemGroup.find_by_id(id)
		if category.nil?
			unless category = Tacos::MenuItemGroup.create!(:id => id, :name => name)
				results[:error] = "Failed to create tacos category."
			end
			results[:action] = "create"		
		else
			#update attributes will return false if the save did not work
			unless category.update_attributes(:name => name)
				results[:error] = "Failed to update tacos category (id: #{category.id})."
			end
			results[:action] = "update"			
		end
		results[:obj] = category
		results
	end
end
