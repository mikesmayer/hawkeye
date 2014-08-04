class Tacos::MenuItem < ActiveRecord::Base
	has_many :meal_count_rules, :dependent => :destroy
	belongs_to :menu_item_group
	belongs_to :ticket_items

=begin
	def get_all_associated_ticket_items
		ticket_ids = Array.new
		self.ticket_items.all.each do |item|
		  ticket_ids << item.ticket_id
		end
		ticket_ids.uniq
	end
=end

	private
	def self.find_or_update_by_id(id, name)
		results = { :action => '', :obj => nil, :error => nil }
		menu_item = Tacos::MenuItem.find_by_id(id)
		if menu_item.nil?
			unless menu_item = Tacos::MenuItem.create(:id => id, :name => name, :menu_item_group_id => -1)
				results[:error] = "Failed to create tacos menu item."
			end
			results[:action] = "create"

			MenuItemMailer.menu_item_added(menu_item).deliver
		else
			unless menu_item.update_attributes(:name => name)
				results[:error] = "Failed to update tacos menu item (id: #{menu_item.id})."
			end
			results[:action] = "update"
		end
		results[:obj] = menu_item
		results
	end

end
