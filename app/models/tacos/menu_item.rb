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
		menu_item = Tacos::MenuItem.find_by_id(id)
		if menu_item.nil?
			menu_item = Tacos::MenuItem.create(:id => id, :name => name, :menu_item_group_id => -1)
		#MenuItemMailer.menu_item_added(menu_item).deliver
		else
			menu_item.update_attributes(:name => name)
		end
		menu_item
	end

end
