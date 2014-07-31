class Tacos::TicketItem < ActiveRecord::Base
	belongs_to :menu_item_group, :foreign_key => :pos_category_id
	belongs_to :menu_item

	validates :pos_ticket_item_id, uniqueness: true

	# Updates the meal count for the ticket item
	def update_meal_count
		#get multiplier will return the appropriate meal multiplier depending on the date
		#as well as the net price of item - $0 items will always have a 0 multiplier (generate no meals)
		modifier = Tacos::MealCountRule.get_multiplier(menu_item_id, ticket_close_time, net_price, discount_total)
		self.update_attributes( :meal_for_meal => (modifier * quantity) )
	end


	def self.find_or_update_by_ticket_item_id(pos_ticket_item_id, pos_ticket_id, menu_item_id, pos_category_id, 
		pos_revenue_class_id, quantity, net_price, discount_total, item_menu_price, ticket_close_time)
  	
		ticket_item = Tacos::TicketItem.find_by_pos_ticket_item_id(pos_ticket_item_id)
		if ticket_item.nil?
			ticket_item = Tacos::TicketItem.create(:pos_ticket_item_id => pos_ticket_item_id, :pos_ticket_id => pos_ticket_id, 
				:menu_item_id => menu_item_id, :pos_category_id => pos_category_id, :pos_revenue_class_id => pos_revenue_class_id,
				:quantity => quantity, :net_price => net_price, :discount_total => discount_total,
				:item_menu_price => item_menu_price, :ticket_close_time => ticket_close_time)			
		else
			ticket_item.update_attributes(:pos_ticket_id => pos_ticket_id, 
				:menu_item_id => menu_item_id, :pos_category_id => pos_category_id, :pos_revenue_class_id => pos_revenue_class_id,
				:quantity => quantity, :net_price => net_price, :discount_total => discount_total,
				:item_menu_price => item_menu_price, :ticket_close_time => ticket_close_time)
		end
		ticket_item.update_meal_count
		ticket_item
	end

end
