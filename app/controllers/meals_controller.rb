class MealsController < ApplicationController
	before_action :set_restaurant, only: [:index, :counts, :month_counts, :year_counts, :count_totals, :product_mix, :category_product_mix]
	before_action :convert_daterange, only: [:index, :counts, :month_counts, :year_counts, :count_totals, :product_mix, :category_product_mix]

	def index
		totals = JSON.parse(Meal.get_meal_totals(@restaurant, @start_date, @end_date))
		@total_meals = totals["total"]
		@m4m = totals["m4m"]
		@dym = totals["dym"]
		@apparel = totals["apparel"]
		@tip_jar = totals["tip_jar"]

		@p42_categories = P42::MenuItemGroup.all
		@tacos_categories = Tacos::MenuItemGroup.all
	end

	#GET /meals/detail_counts
	def counts
		@granularity = params[:granularity]

		@detail_totals = Meal.get_meal_breakdown(@restaurant, @granularity, @start_date, @end_date)
		
		
		respond_to do |format|
			format.js { render :layout => false }
			format.csv { send_data Meal.details_to_csv(@detail_totals) }
		end
		

	end

	#GET /meals/month_counts
	def month_counts
		@month_totals = Meal.get_month_breakdown(@restaurant, @start_date, @end_date)
		render :layout => false
	end

	#GET /meals/year_counts
	def year_counts
		@year_totals = Meal.get_year_breakdown(@restaurant, @start_date, @end_date)
		render :layout => false
	end

	def count_totals
		@count_totals = Meal.get_meal_totals(@restaurant, @start_date, @end_date)
		
		response.header['Content-Type'] = 'application/json'
		respond_to do |format|
	        format.js { render json: @count_totals }
	        format.json { render json: @count_totals }	      
	    end
	end

	def product_mix
		@product_mix = Meal.get_product_mix(@restaurant, @start_date, @end_date)
		respond_to do |format|
			format.js 	{ render :layout => false }
		end
	end

	def category_product_mix
		@item_mix_by_category = Meal.get_category_breakdown(@restaurant, params[:category_id], @start_date, @end_date)
		respond_to do |format|
			format.js 	{ render :layout => false }
		end
	end


	private

	  def set_restaurant 
		@restaurant = params[:restaurant] || "p42"
	  end


	  def convert_daterange
	  	date_range = params[:date_range]

	  	#Sets granularity to custom if it isn't one of the presets
		unless ["current_year", "current_month", "current_week", "all"].include?(date_range) || date_range.nil?
			start_end = date_range
			date_range = "custom"
		end


		case date_range
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
			
			dates = start_end.split('T', 2)
			@start_date = Date.parse(dates[0])
			@end_date = Date.parse(dates[1])
			
		else
			@start_date = Date.today - 100.years
			@end_date = Date.today + 100.years
		end
	  end
end