class TipJarDonation < ActiveRecord::Base
	belongs_to :restaurant

	validates :amount, presence: true
	validates :amount, :numericality => { :greater_than => 0 }
	validates :deposit_date, date: { before: Proc.new { Date.today + 1.day }, message: 'Must be in the past' }
	validates :deposit_date, date: { message: "Not a valid end date. Use the format YYYY-MM-DD" }
	validates :restaurant_id, presence: true

	after_save :update_meal_amount

	def update_meal_amount
		meals = self.amount / 0.22
		self.update_columns(:meals => meals)
	end
end
