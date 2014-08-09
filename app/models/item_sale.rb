class ItemSale

	# Generates a csv matching the aggregate items sales table on the index page (i.e. 
	#	aggregate sales info by day, month, quarter, year)
	def self.details_to_csv(details_tbl)
		CSV.generate do |csv|
			csv << ["Date", "Net Sales", "Food", "Merchandise", "Donation", "Discounts", "M4m"]

			details_tbl.each do |row|
				csv << [row.date, row.total_net_sales, row.total_food_sales, row.total_merch_sales,
					row.total_donation, row.total_discounts, row.meal_for_meal]
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
										p42_menu_item_groups.name AS \"category_name\", quantity, net_price, 
										discount_total, item_menu_price, meal_for_meal")
					.joins("LEFT JOIN p42_menu_items ON p42_menu_items.id = p42_ticket_items.menu_item_id")
					.joins("LEFT JOIN p42_menu_item_groups ON p42_menu_item_groups.id = p42_ticket_items.pos_category_id")
					.where("ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'")
					.order("ticket_close_time ASC")
					

					


		elsif restaurant == "tacos"
			finder = Tacos::TicketItem.select("tacos_ticket_items.id, pos_ticket_item_id, pos_ticket_id, 
										ticket_close_time AS \"time\", tacos_menu_items.name AS \"item_name\", 
										tacos_menu_item_groups.name AS \"category_name\", quantity, net_price,
										discount_total, item_menu_price, meal_for_meal")
					.joins("LEFT JOIN tacos_menu_items ON tacos_menu_items.id = tacos_ticket_items.menu_item_id")
					.joins("LEFT JOIN tacos_menu_item_groups ON tacos_menu_item_groups.id = tacos_ticket_items.pos_category_id")
					.where("ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'")
					.order("ticket_close_time ASC")
		end

		
		CSV.generate do |csv|
			csv << ["Ticket Item Id", "Ticket Id", "Time", "Item Name", "Category Name", "Quantity", "Net Price", "Discount Total", "Menu Price", "M4M"]

			finder.find_each(batch_size: 10000) do |row|
				csv << [row.pos_ticket_item_id, row.pos_ticket_id, row.time, row.item_name, row.category_name, row.quantity, row.net_price, row.discount_total, row.item_menu_price, row.meal_for_meal]
			end
		end
		

	end



	def self.get_sales_totals(restaurant, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		if restaurant == "p42"
			net_sales = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:net_price)
			discount_totals = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:discount_total)
			m4m_totals = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:meal_for_meal)
			tip_jar_totals = TipJarDonation.where("deposit_date BETWEEN ? AND ?", start_date, end_date)
				.where("restaurant_id = 1").sum(:meals)
			food_sales = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date)
						.where("pos_revenue_class_id = 11").sum(:net_price)
			merch_sales = P42::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date)
						.where("pos_revenue_class_id = 18").sum(:net_price)
		elsif restaurant == "tacos"
			net_sales = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:net_price)
			discount_totals = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:discount_total)
			m4m_totals = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date).sum(:meal_for_meal)
			tip_jar_totals = TipJarDonation.where("deposit_date BETWEEN ? AND ?", start_date, end_date)
				.where("restaurant_id = 2").sum(:meals)
			food_sales = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date)
						.where("pos_category_id IN(1,2,3,4,5,6,7,8,9)").sum(:net_price)
			merch_sales = Tacos::TicketItem.where("ticket_close_time BETWEEN ? AND ?", start_date, end_date)
						.where("pos_category_id = 11").sum(:net_price)
		end

		net_sales = net_sales.nil? ? 0 : net_sales
		discount_totals = discount_totals.nil? ? 0 : discount_totals
		m4m_totals = m4m_totals.nil? ? 0 : m4m_totals
		tip_jar_totals = tip_jar_totals.nil? ? 0 : tip_jar_totals

		food_sales = food_sales.nil? ? 0 : food_sales
		merch_sales = merch_sales.nil? ? 0 : merch_sales
		#have to include everything genearted in the restaurant and tip jar donations
		m4m_totals = m4m_totals + tip_jar_totals

		totals = {:net_sales => net_sales, :discount_totals => discount_totals, 
			:m4m_totals => m4m_totals, :food_sales => food_sales, :merch_sales => merch_sales}
		totals.to_json
	end

	def self.get_category_totals(restaurant, start_date, end_date)
		totals_array = Array.new
		category_names = Array.new
		all_cat_total = 0
		
		if restaurant == "p42"
			#categories = P42::MenuItemGroup.all
			category_totals = P42::TicketItem.find_by_sql("SELECT name, SUM(net_price) as net_price
				  FROM p42_ticket_items
				  INNER JOIN p42_menu_item_groups ON p42_menu_item_groups.id = p42_ticket_items.pos_category_id
				  WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59' 
				  GROUP BY name
				  ORDER BY net_price DESC")

			category_totals.each do |cat|

				total = cat.net_price.round(2)
				unless total < 0.01
					category_names << cat.name
					totals_array << total
					all_cat_total += total
				end
			end


			

		elsif restaurant == "tacos"
			category_totals = Tacos::TicketItem.find_by_sql("SELECT name, SUM(net_price) as net_price
				  FROM tacos_ticket_items
				  INNER JOIN tacos_menu_item_groups ON tacos_menu_item_groups.id = tacos_ticket_items.pos_category_id
				  WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59' 
				  GROUP BY name
				  ORDER BY net_price DESC")
			
			category_totals.each do |cat|
				total = cat.net_price.round(2)
				unless total < 0.01
					category_names << cat.name
					totals_array << total
					all_cat_total += total
				end
			end
		end

		totals = { :columns => category_names, :totals => totals_array, :all_cat_total => all_cat_total}
	end

	def self.getAggregateSales(restaurant, granularity, start_date, end_date)
		
	   # start_date = '2000-01-01'
	   # end_date = '2100-01-01'

		case granularity
		when "day"
			outer_query_date = "to_char(t1.date, 'Mon DD, YYYY')"
		when "month"
			outer_query_date = "to_char(t1.date, 'Mon, YYYY')"
		when "quarter"
			outer_query_date = "'Q' || to_char(t1.date, 'Q YYYY')"
		when "year"
	    	outer_query_date = "to_char(t1.date, 'YYYY')"
	    end
	    
	    if restaurant == "p42"
=begin	    	
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
=end

			P42::TicketItem.find_by_sql("SELECT #{outer_query_date} AS date, SUM(COALESCE(total_net_sales,0)) AS total_net_sales, 
				SUM( COALESCE(total_discounts, 0) ) AS total_discounts, 
				SUM( COALESCE(t1.meal_for_meal,0)+COALESCE(t2.meals,0) ) AS meal_for_meal, 
				SUM( COALESCE(total_food_sales,0) ) AS total_food_sales,
				SUM( COALESCE(total_merch_sales,0) ) AS total_merch_sales, 
				SUM( COALESCE(total_donation,0) ) AS total_donation
					FROM 
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_net_sales,
						SUM(discount_total) AS total_discounts,
						SUM(meal_for_meal) AS meal_for_meal
						FROM p42_ticket_items
						WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
						GROUP BY date
						ORDER BY date ) t1
				LEFT JOIN 
					(SELECT date_trunc('#{granularity}', deposit_date) as date,
					SUM(meals) as meals
					FROM tip_jar_donations
					WHERE restaurant_id = 1 AND deposit_date BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					GROUP BY  date) t2
				ON t1.date = t2.date			
				LEFT JOIN
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_food_sales
					FROM p42_ticket_items
					WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					AND pos_revenue_class_id = 11
					GROUP BY date) t3
				ON t1.date = t3.date
				LEFT JOIN 
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_merch_sales
					FROM p42_ticket_items
					WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					AND pos_revenue_class_id = 18
					GROUP BY date) t4
				ON t1.date = t4.date
				LEFT JOIN 
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_donation
					FROM p42_ticket_items
					WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					AND pos_revenue_class_id = 15
					GROUP BY date) t5
				ON t1.date = t5.date
			GROUP BY t1.date
			ORDER BY t1.date ASC")
	    elsif restaurant == "tacos"
=begin
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

=end
			Tacos::TicketItem.find_by_sql("SELECT #{outer_query_date} AS date, SUM(COALESCE(total_net_sales,0)) AS total_net_sales, 
				SUM( COALESCE(total_discounts, 0) ) AS total_discounts, 
				SUM( COALESCE(t1.meal_for_meal,0)+COALESCE(t2.meals,0) ) AS meal_for_meal, 
				SUM( COALESCE(total_food_sales,0) ) AS total_food_sales,
				SUM( COALESCE(total_merch_sales,0) ) AS total_merch_sales, 
				SUM( COALESCE(total_donation,0) ) AS total_donation
					FROM 
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_net_sales,
						SUM(discount_total) AS total_discounts,
						SUM(meal_for_meal) AS meal_for_meal
						FROM tacos_ticket_items
						WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
						GROUP BY date
						ORDER BY date ) t1
				LEFT JOIN 
					(SELECT date_trunc('#{granularity}', deposit_date) as date,
					SUM(meals) as meals
					FROM tip_jar_donations
					WHERE restaurant_id = 2 AND deposit_date BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					GROUP BY  date) t2
				ON t1.date = t2.date			
				LEFT JOIN
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_food_sales
					FROM tacos_ticket_items
					WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					AND pos_category_id IN(1,2,3,4,5,6,7,8,9)
					GROUP BY date) t3
				ON t1.date = t3.date
				LEFT JOIN 
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_merch_sales
					FROM tacos_ticket_items
					WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					AND pos_category_id = 11
					GROUP BY date) t4
				ON t1.date = t4.date
				LEFT JOIN 
					(SELECT date_trunc('#{granularity}', ticket_close_time) as date,
						SUM(net_price) AS total_donation
					FROM tacos_ticket_items
					WHERE ticket_close_time BETWEEN '#{start_date}T00:00:00' AND '#{end_date}T23:59:59'
					AND pos_category_id = 10
					GROUP BY date) t5
				ON t1.date = t5.date
			GROUP BY t1.date
			ORDER BY t1.date ASC")

	    end


	end




end