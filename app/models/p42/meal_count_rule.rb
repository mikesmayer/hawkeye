class P42::MealCountRule < ActiveRecord::Base
	belongs_to :menu_item

	validates :meal_modifier, presence: true
	validates :meal_modifier, :numericality => { :greater_than_or_equal_to => 0 }
	validates :menu_item_id, presence: true
	validates :start_date, date: { message: "Not a valid start date. Use the format YYYY-MM-DD", allow_nil: true }
	validates :end_date, date: { message: "Not a valid end date. Use the format YYYY-MM-DD", allow_nil: true }
	validate :end_date_after_start_date, :rule_conflict
	

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


	def end_date_after_start_date
		set_empty_dates

		if end_date < start_date
			errors.add(:end_date, "End date must be after the start date")
		end
	end

	# This method check to make sure the rule does not conflict with a rule that's
	# already in place for the specified menu item. i.e. you cannot have a rule that 
	# sets a meal modifier for a menu item for a given date when a rule already exists 
	# for that date
	def rule_conflict
		menu_item = P42::MenuItem.find(menu_item_id)
		rules = menu_item.meal_count_rules

		rules.each do |rule|
			if rule.id != self.id && overlaps?(rule)
				errors.add(:end_date, "The dates for this rule overlap with a rule already created for this menu item.")
			end
		end
	end

	def overlaps?(other)
		(start_date - other.end_date) * (other.start_date - end_date) >= 0
	end

end
