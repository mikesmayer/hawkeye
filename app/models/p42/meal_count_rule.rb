class P42::MealCountRule < ActiveRecord::Base
	belongs_to :menu_item

	validates :meal_modifier, presence: true
	validates :meal_modifier, numericality: true
	validates :menu_item_id, presence: true
	

	before_save :set_empty_dates
	## TODO Add custom validation to verify dates are okay



	## this is the date that all meal count rules use to indicate that the rule
	# starts from the beginning of restaurant time
	# these two variables used together denote a rule that is applicable for all time
	def self.RULE_START_DATE_FLAG
		Date.new(2000,1,1)
	end

	## This is the date that all meal count rules use to indicate that the
	# rule does not end 
	# these two variables used together denote a rule that is applicable for all time
	def self.RULE_END_DATE_FLAG
		Date.new(2100,12,31)
	end

	private

	#Method called before save, it just checks to see if the dates are empty and 
	#sets them to the flag dates to indicate that the rule is applicable for all time
	def set_empty_dates
		if !attribute_present?("start_date")
			self.start_date = P42::MealCountRule.RULE_START_DATE_FLAG
		end

		if !attribute_present?('end_date')
			self.end_date = P42::MealCountRule.RULE_END_DATE_FLAG
		end
	end
end
