class MealsController < ApplicationController

	def index
		totals = P42::TicketItem.get_meal_totals
		@total_meals = totals[:total]
		@m4m = totals[:m4m]
		@dym = totals[:dym]
		@apparel = totals[:apparel]
		@tip_jar = totals[:tip_jar]
	end

	# GET /meals/counts
	def counts
		@detail_totals = P42::TicketItem.get_meal_breakdown(params[:granularity])
		render :layout => false
	end

	# GET /meals/month_counts
	def month_counts
		@month_totals = P42::TicketItem.get_month_breakdown
		render :layout => false
	end

	def year_counts
		@year_totals = P42::TicketItem.get_year_breakdown
		render :layout => false
	end
end