class P42::TicketItem < ActiveRecord::Base
  belongs_to :ticket, :dependent => :destroy
  belongs_to :revenue_group
  belongs_to :menu_item_group
  belongs_to :menu_item
  has_many :discount_items, :dependent => :destroy, :foreign_key => :pos_ticket_item_id

  validates :pos_ticket_item_id, :uniqueness => true

  def self.find_or_update_by_ticket_item_id(pos_ticket_item_id, pos_ticket_id, ticket_id, menu_item_id, net_price, gross_price, manual_discount, auto_discount, item_qty, revenue_group_id, menu_item_group_id, meal_for_meal)
  	ticket_item = P42::TicketItem.find_by_pos_ticket_item_id(pos_ticket_item_id)
  	if ticket_item.nil?
  		ticket_item = P42::TicketItem.create(:pos_ticket_item_id => pos_ticket_item_id, :pos_ticket_id => pos_ticket_id, :ticket_id => ticket_id, 
  			:menu_item_id => menu_item_id, :net_price => net_price, :gross_price => gross_price, :manual_discount => manual_discount,
  			:auto_discount => auto_discount, :item_qty => item_qty, :revenue_group_id => revenue_group_id,
        :menu_item_group_id => menu_item_group_id, :meal_for_meal => meal_for_meal)
  	else
  		ticket_item.update_attributes(:pos_ticket_id => pos_ticket_id, :ticket_id => ticket_id, 
  			:menu_item_id => menu_item_id, :net_price => net_price, :gross_price => gross_price, :manual_discount => manual_discount,
  			:auto_discount => auto_discount, :item_qty => item_qty, :revenue_group_id => revenue_group_id, 
        :menu_item_group_id => menu_item_group_id, :meal_for_meal => meal_for_meal)
  	end
  	ticket_item
  end
end
