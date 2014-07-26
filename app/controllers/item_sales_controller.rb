class ItemSalesController < ApplicationController
	before_action :convert_daterange, only: [:index, :aggregate_items, :items]

	def index
		@item_sales = P42::TicketItem.find(:all, :limit => 5)

		respond_to do |format|
			format.html
		end
	end

	def items
		respond_to do |format|
			format.json { render json: ItemSaleDatatable.new(view_context,
				{ :start_date => @start_date, :end_date => @end_date }) }
			format.csv { send_data ItemSale.item_sales_details_to_csv(@start_date, @end_date) }
		end
	end

	def aggregate_items
		@granularity = params[:granularity]
		@aggregate_table_rows = ItemSale.getAggregateSales(@granularity, @start_date, @end_date)

		respond_to do |format|
			format.js { render :layout => false  }
			format.csv { send_data ItemSale.details_to_csv(@aggregate_table_rows) }
		end
	end

	private
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