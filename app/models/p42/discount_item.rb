class P42::DiscountItem < ActiveRecord::Base
	belongs_to :ticket
	belongs_to :ticket_item, :primary_key => :pos_ticket_item_id
end
