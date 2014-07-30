class Tacos::MenuItemGroup < ActiveRecord::Base
	has_many :menu_items



	def self.find_or_update_by_id(id, name)
  	
		category = Tacos::MenuItemGroup.find_by_id(id)
		if category.nil?
			category = Tacos::MenuItemGroup.create(:id => id, :name => name)			
		else
			category.update_attributes(:name => name)
		end
		category
	end
end
