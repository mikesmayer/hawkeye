class ItemSalesController < ApplicationController
	authorize_resource
	before_action :convert_daterange, only: [:index, :aggregate_items, :details, 
		:sales_totals, :sales_details, :category_totals, :item_totals]
	before_action :set_restaurant, only: [:sales_details, :aggregate_items, :sales_totals,
		:category_totals, :item_totals]
	def index
		@p42_categories = P42::MenuItemGroup.all
		@tacos_categories = Tacos::MenuItemGroup.all

		respond_to do |format|
			format.html
		end
	end

	def details
		respond_to do |format|
			format.html
		end
	end

	def sales_details
		respond_to do |format|
			format.json { render json: ItemSaleDatatable.new(view_context,
				{ :restaurant => @restaurant, :start_date => @start_date, :end_date => @end_date }) }
			format.csv { send_data ItemSale.item_sales_details_to_csv(@restaurant, @start_date, @end_date), :content_type => 'text/csv' }
			
		end
	end

	def aggregate_items
		@granularity = params[:granularity]
		@aggregate_table_rows = ItemSale.getAggregateSales(@restaurant, @granularity, @start_date, @end_date)

		respond_to do |format|
			format.js { render :layout => false  }
			format.csv { send_data ItemSale.details_to_csv(@aggregate_table_rows) }
		end
	end

	def sales_totals
		@totals = ItemSale.get_sales_totals(@restaurant, @start_date, @end_date)

		response.header['Content-Type'] = 'application/json'
		respond_to do |format|
			format.js { render json: @totals }
			format.json { render json: @totals }
		end
	end

	def category_totals
		@category_totals = ItemSale.get_category_totals(@restaurant, @start_date, @end_date)

		response.header['Content-Type'] = 'application/json'
		respond_to do |format|
			format.js { render json: @category_totals }
		end
	end

	def item_totals
		@category_id = ItemSale.get_item_totals(@restaurant, @start_date, @end_date, params[:category_id])

		response.header['Content-Type'] = 'application/json'
		respond_to do |format|
			format.js { render json: @category_id }
		end
	end

	private
	  def set_restaurant
	  	@restaurant = params[:restaurant]
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