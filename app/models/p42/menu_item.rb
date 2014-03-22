class P42::MenuItem < ActiveRecord::Base
	has_many :meal_count_rule, dependent: :destroy
	belongs_to :menu_item_group
	belongs_to :revenue_group
end
