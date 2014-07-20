class MealsController < ApplicationController

	before_action :convert_daterange, only: [:index, :counts, :month_counts, :year_counts, :count_totals]

	def index
		totals = JSON.parse(P42::TicketItem.get_meal_totals(@start_date, @end_date))
		@total_meals = totals["total"]
		@m4m = totals["m4m"]
		@dym = totals["dym"]
		@apparel = totals["apparel"]
		@tip_jar = totals["tip_jar"]
	end

	#GET /meals/counts
	def counts
		@detail_totals = P42::TicketItem.get_meal_breakdown(params[:granularity], @start_date, @end_date)
		render :layout => false
	end

	#GET /meals/month_counts
	def month_counts
		@month_totals = P42::TicketItem.get_month_breakdown(@start_date, @end_date)
		render :layout => false
	end

	#GET /meals/year_counts
	def year_counts
		@year_totals = P42::TicketItem.get_year_breakdown(@start_date, @end_date)
		render :layout => false
	end

	def count_totals
		@count_totals = P42::TicketItem.get_meal_totals(@start_date, @end_date)
		
		response.header['Content-Type'] = 'application/json'
		respond_to do |format|
	        format.js { render json: @count_totals }
	        format.json { render json: @count_totals }	      
	    end
	end

	private
	  def convert_daterange
		case params[:date_range]
		when "current_year"
			@start_date = Date.today.beginning_of_year
			@end_date = Date.today
		when "current_month"
			@start_date = Date.today.beginning_of_month
			@end_date = Date.today
		when "current_week"
			@start_date = Date.today.beginning_of_week
			@end_date = Date.today
		when "custom"
			@start_date = Date.today - 100.years
			@end_date = Date.today + 100.years
		else 
			@start_date = Date.today - 100.years
			@end_date = Date.today + 100.years
		end
	  end
end