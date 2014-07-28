class ItemSale

	# Generates a csv matching the aggregate items sales table on the index page (i.e. 
	#	aggregate sales info by day, month, quarter, year)
	def self.details_to_csv(details_tbl)
		CSV.generate do |csv|
			csv << ["Date", "Total Net Sales", "Total Discounts", "Total M4m"]

			details_tbl.each do |row|
				csv << [row.date, row.total_net_sales, row.total_discounts, row.meal_for_meal]
			end
		end
	end

	# Generates a csv of item level sales data between the start and end dates
	def self.item_sales_details_to_csv(restaurant, start_date, end_date)
=begin
		items = P42::TicketItem.find_by_sql("SELECT to_char(ticket_close_time, 'YYYY-MM-DD HH:MMam') AS time,
			item_name,
			category_name,
			quantity,
			net_price,
			meal_for_meal
		FROM
		(SELECT  ticket_close_time,
			p42_menu_items.name AS item_name,
			p42_menu_item_groups.name AS category_name,
			quantity,
			net_price,
			meal_for_meal			
		FROM p42_ticket_items
		LEFT JOIN p42_menu_items ON p42_menu_items.id = p42_ticket_items.menu_item_id
		LEFT JOIN p42_menu_item_groups ON p42_menu_item_groups.id = p42_ticket_items.pos_category_id
		WHERE ticket_close_time BETWEEN '2000-01-01T00:00:00' AND '2100-01-01T23:59:59'
		ORDER BY ticket_close_time) t1")
=end
		
		if restaurant == "p42"
			finder = P42::TicketItem.select("p42_ticket_items.id, pos_ticket_item_id, pos_ticket_id, 
										ticket_close_time AS \"time\", p42_menu_items.name AS \"item_name\", 
										p42_menu_item_groups.name AS \"category_name\", quantity, net_price, meal_for_meal")
					.joins("LEFT JOIN p42_menu_items ON p42_menu_items.id = p42_ticket_items.menu_item_id")
					.joins("LEFT JOIN p42_menu_item_groups ON p42_menu_item_groups.id = p42_ticket_items.pos_category_id")
					.where("ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'")
					.order("ticket_close_time ASC")
					

					

			CSV.generate do |csv|
				csv << ["Ticket Item Id", "Ticket Id", "Time", "Item Name", "Category Name", "Quantity", "Net Price", "M4M"]

				finder.find_each(batch_size: 10000) do |row|
					csv << [row.pos_ticket_item_id, row.pos_ticket_id, row.time, row.item_name, row.category_name, row.quantity, row.net_price, row.meal_for_meal]
				end
			end

		elsif restaurant == "tacos"

		end

		
		

	end



	def self.get_sales_totals(restaurant, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		if restaurant == "p42"
			net_sales = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:net_price)
			discount_totals = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:discount_total)
			m4m_totals = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:meal_for_meal)
		elsif restaurant == "tacos"
			net_sales = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:net_price)
			discount_totals = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:discount_total)
			m4m_totals = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:meal_for_meal)
		end

		net_sales = net_sales.nil? ? 0 : net_sales
		discount_totals = discount_totals.nil? ? 0 : discount_totals
		m4m_totals = m4m_totals.nil? ? 0 : m4m_totals

		totals = {:net_sales => net_sales, :discount_totals => discount_totals, :m4m_totals => m4m_totals}
		totals.to_json
	end


	def self.getAggregateSales(restaurant, granularity, start_date, end_date)
		
	   # start_date = '2000-01-01'
	   # end_date = '2100-01-01'

		case granularity
		when "day"
			outer_query_date = "to_char(date, 'Mon DD, YYYY')"
		when "month"
			outer_query_date = "to_char(date, 'Mon, YYYY')"
		when "quarter"
			outer_query_date = "'Q' || to_char(date, 'Q YYYY')"
		when "year"
	    	outer_query_date = "to_char(date, 'YYYY')"
	    end
	    
	    if restaurant == "p42"
	    	
	    	P42::TicketItem.find_by_sql("SELECT #{outer_query_date} AS date, total_net_sales, total_discounts, meal_for_meal 
			FROM 
			(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
				SUM(net_price) AS total_net_sales,
				SUM(discount_total) AS total_discounts,
				SUM(meal_for_meal) AS meal_for_meal
				FROM p42_ticket_items
				WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
				GROUP BY date
				ORDER BY date ) t1")
	    elsif restaurant == "tacos"
	    	Tacos::TicketItem.find_by_sql("SELECT #{outer_query_date} AS date, total_net_sales, total_discounts, meal_for_meal 
			FROM 
			(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
				SUM(net_price) AS total_net_sales,
				SUM(discount_total) AS total_discounts,
				SUM(meal_for_meal) AS meal_for_meal
				FROM tacos_ticket_items
				WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
				GROUP BY date
				ORDER BY date ) t1")
	    end


	end




end