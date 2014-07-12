class MealsController < ApplicationController

	def index
		totals = P42::TicketItem.get_meal_totals
		@total_meals = totals[:total]
		@m4m = totals[:m4m]
		@dym = totals[:dym]
		@apparel = totals[:apparel]
	end

	# GET /meals/counts
	def counts
		@day_totals = P42::TicketItem.get_meal_breakdown
		render :layout => false
	end

end