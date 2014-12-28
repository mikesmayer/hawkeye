class Meal


	def self.details_to_csv(details_tbl)
		CSV.generate do |csv|
			csv << ["Date", "Meal4Meal", "Double", "Apparel", "Tips", "One Time", "Total"]

			details_tbl.each do |row|
				csv << [row.date, row.m4m, row.dym, row.apparel, row.tip_jar, row.one_time, row.total]
			end
		end
	end

	def self.get_meal_totals(restaurant, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		if restaurant == "p42"
			totals = P42::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.sum(:meal_for_meal)

			m4m_total = P42::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("pos_revenue_class_id != 15 AND pos_revenue_class_id != 18")
				.sum(:meal_for_meal)
			
			dym_total = P42::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("pos_revenue_class_id = 15")
				.sum(:meal_for_meal)
			
			apparel_total = P42::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("pos_revenue_class_id = 18")
				.sum(:meal_for_meal)
			
			tip_jar_total = TipJarDonation
				.where("deposit_date between ? AND ?", start_date, end_date)
				.where("restaurant_id = 1")
				.sum(:meals)

			one_time_total = OneTimeDonation
				.where("deposit_date between ? AND ?", start_date, end_date)
				.where("restaurant_id = 1")
				.sum(:meals)

			totals += one_time_total
			totals += tip_jar_total
		elsif restaurant == "tacos"
			totals = Tacos::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("(void IS NULL OR void != 'TRUE')")
				.sum(:meal_for_meal)

			# Geting the m4m numbers by summing everything in the following food categories:
			# 1 - Salad & Rice Bowls
			# 2 - Classic Tacos
			# 3 - Quirky Tacos
			# 4 - Quesadilla & Burrito
			# 5 - Kids
			# 15 - CATERING
			#
			m4m_total = Tacos::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("pos_category_id IN (1, 2, 3, 4, 5, 15)")
				.where("(void IS NULL OR void != 'TRUE')")
				.sum(:meal_for_meal)
			
			# Getting the double your meal donation using the item number for donation (7000)
			dym_total = Tacos::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("menu_item_id = 7000")
				.where("(void IS NULL OR void != 'TRUE')")
				.sum(:meal_for_meal)
			
			# Getting apparel number using the category id for merchandise (11)
			apparel_total = Tacos::TicketItem
				.where("ticket_close_time between ? AND ?", start_date, end_date)
				.where("pos_category_id = 11")
				.where("(void IS NULL OR void != 'TRUE')")
				.sum(:meal_for_meal)
			
			tip_jar_total = TipJarDonation
				.where("deposit_date between ? AND ?", start_date, end_date)
				.where("restaurant_id = 2")
				.sum(:meals)

			one_time_total = OneTimeDonation
				.where("deposit_date between ? AND ?", start_date, end_date)
				.where("restaurant_id = 2")
				.sum(:meals)

			totals += one_time_total
			totals += tip_jar_total
		end

		totals = totals.nil? ? 0 : totals
		m4m_total = m4m_total.nil? ? 0 : m4m_total
		dym_total = dym_total.nil? ? 0 : dym_total
		apparel_total = apparel_total.nil? ? 0 : apparel_total
		tip_jar_total = tip_jar_total.nil? ? 0 : tip_jar_total
		one_time_total = one_time_total.nil? ? 0 : one_time_total

		meal_nums = {:total => totals, :m4m => m4m_total, 
			:dym => dym_total, :apparel => apparel_total, :tip_jar => tip_jar_total, :one_time => one_time_total}
		meal_nums.to_json
	end

	def self.get_month_breakdown(restaurant, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		if restaurant == "p42"
			P42::TicketItem.find_by_sql("SELECT t1.month as month, 
					SUM( COALESCE(t1.total,0) + COALESCE(t2.total,0) + COALESCE(t3.total,0) ) as total
				FROM
				(SELECT DATE_TRUNC('month', ticket_close_time) AS month, SUM(meal_for_meal) as total
				  FROM p42_ticket_items
				  WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('month', ticket_close_time)) t1
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('month', deposit_date) as month
				  FROM tip_jar_donations
				  WHERE restaurant_id = 1 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('month', deposit_date)
				) t2
				  ON t1.month = t2.month
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('month', deposit_date) as month
				  FROM one_time_donations
				  WHERE restaurant_id = 1 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('month', deposit_date)
				) t3
				  ON t1.month = t3.month
				  GROUP BY t1.month
				  ORDER BY t1.month ASC")
		elsif restaurant == "tacos"
			Tacos::TicketItem.find_by_sql("SELECT t1.month as month, 
					SUM( COALESCE(t1.total,0) + COALESCE(t2.total,0) + COALESCE(t3.total,0) ) as total
				FROM
				(SELECT DATE_TRUNC('month', ticket_close_time) AS month, SUM(meal_for_meal) as total
				  FROM tacos_ticket_items
				  WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('month', ticket_close_time)) t1
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('month', deposit_date) as month
				  FROM tip_jar_donations
				  WHERE restaurant_id = 2 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('month', deposit_date)
				) t2
				ON t1.month = t2.month
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('month', deposit_date) as month
				  FROM one_time_donations
				  WHERE restaurant_id = 2 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('month', deposit_date)
				) t3
				ON t1.month = t3.month
				  GROUP BY t1.month
				  ORDER BY t1.month ASC")
		end


	end

	def self.get_year_breakdown(restaurant, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		if restaurant == "p42"
			
			P42::TicketItem.find_by_sql("SELECT t1.year as year, 
				SUM( COALESCE(t1.total,0) + COALESCE(t2.total,0) + COALESCE(t3.total,0) ) as total
				FROM
				(SELECT DATE_TRUNC('year', ticket_close_time) AS year, SUM(meal_for_meal) as total
				  FROM p42_ticket_items
				  WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('year', ticket_close_time)) t1
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('year', deposit_date) as year
				  FROM tip_jar_donations
				  WHERE restaurant_id = 1 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('year', deposit_date)
				  ) t2
				  ON t1.year = t2.year
				LEFT JOIN (
					SELECT SUM(meals) as total, DATE_TRUNC('year', deposit_date) as year
					FROM one_time_donations
					WHERE restaurant_id = 1 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  	GROUP BY DATE_TRUNC('year', deposit_date)
					) t3
				ON t1.year = t3.year
				  GROUP BY t1.year
				  ORDER BY t1.year ASC")

		elsif restaurant == "tacos"
			Tacos::TicketItem.find_by_sql("SELECT t1.year as year, 
				SUM( COALESCE(t1.total,0) + COALESCE(t2.total,0) + COALESCE(t3.total,0) ) as total
				FROM
				(SELECT DATE_TRUNC('year', ticket_close_time) AS year, SUM(meal_for_meal) as total
				  FROM tacos_ticket_items
				  WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('year', ticket_close_time)) t1
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('year', deposit_date) as year
				  FROM tip_jar_donations
				  WHERE restaurant_id = 2 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('year', deposit_date)
				  ) t2
				  ON t1.year = t2.year
				LEFT JOIN (
				SELECT SUM(meals) as total, DATE_TRUNC('year', deposit_date) as year
				  FROM one_time_donations
				  WHERE restaurant_id = 2 AND deposit_date between '#{start_date}' AND '#{end_date}'
				  GROUP BY DATE_TRUNC('year', deposit_date)
				  ) t3
				  ON t1.year = t3.year
				  GROUP BY t1.year
				  ORDER BY t1.year ASC")
		end
				

	end


	def self.get_product_mix(restaurant, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		if restaurant == "p42"
			mix_table = P42::TicketItem.find_by_sql("SELECT p42_menu_item_groups.id, p42_menu_item_groups.name,
			       SUM(quantity) AS quantity, SUM(net_price) AS net_price, SUM(discount_total) AS discount_total, SUM(item_menu_price) AS item_price, 
			       SUM(meal_for_meal) AS m4m
			  FROM p42_ticket_items
			  INNER JOIN p42_menu_item_groups ON p42_ticket_items.pos_category_id = p42_menu_item_groups.id
			  WHERE ticket_close_time BETWEEN '#{start_date}' AND '#{end_date}'
			  GROUP BY p42_menu_item_groups.id, p42_menu_item_groups.name
			  ORDER BY m4m DESC")
		elsif restaurant == "tacos"
			mix_table = Tacos::TicketItem.find_by_sql("SELECT tacos_menu_item_groups.id, tacos_menu_item_groups.name,
			       SUM(quantity) AS quantity, SUM(net_price) AS net_price, SUM(discount_total) AS discount_total, SUM(item_menu_price) AS item_price, 
			       SUM(meal_for_meal) AS m4m
			  FROM tacos_ticket_items
			  INNER JOIN tacos_menu_item_groups ON tacos_ticket_items.pos_category_id = tacos_menu_item_groups.id
			  WHERE ticket_close_time BETWEEN '#{start_date}' AND '#{end_date}'
			  GROUP BY tacos_menu_item_groups.id, tacos_menu_item_groups.name
			  ORDER BY m4m DESC")

		end

		mix_table
	end


	def self.get_category_breakdown(restaurant, cateogry_id, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"


		if restaurant == "p42"
			item_mix_by_category = P42::TicketItem.find_by_sql("SELECT p42_menu_items.id, p42_menu_items.name,
			       SUM(quantity) AS quantity, SUM(net_price) AS net_price, SUM(discount_total) AS discount_total, SUM(item_menu_price) AS item_price, 
			       SUM(meal_for_meal) AS m4m
			  FROM p42_ticket_items
			  INNER JOIN p42_menu_items ON p42_ticket_items.menu_item_id = p42_menu_items.id
			  WHERE ticket_close_time BETWEEN '#{start_date}' AND '#{end_date}'
				AND pos_category_id = #{cateogry_id}
			  GROUP BY p42_menu_items.id, p42_menu_items.name
			  ORDER BY m4m DESC")
		elsif restaurant == "tacos"
			item_mix_by_category = Tacos::TicketItem.find_by_sql("SELECT tacos_menu_items.id, tacos_menu_items.name,
			       SUM(quantity) AS quantity, SUM(net_price) AS net_price, SUM(discount_total) AS discount_total, SUM(item_menu_price) AS item_price, 
			       SUM(meal_for_meal) AS m4m
			  FROM tacos_ticket_items
			  INNER JOIN tacos_menu_items ON tacos_ticket_items.menu_item_id = tacos_menu_items.id
			  WHERE ticket_close_time BETWEEN '#{start_date}' AND '#{end_date}'
				AND pos_category_id = #{cateogry_id}
			  GROUP BY tacos_menu_items.id, tacos_menu_items.name
			  ORDER BY m4m DESC")
		end

		item_mix_by_category
	end


	def self.get_meal_breakdown(restaurant, granularity, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"
		#dates = P42::TicketItem.select("date(ticket_close_time) as date").group("date(ticket_close_time)")

		#P42::TicketItem.select("date(ticket_close_time) as date, sum(meal_for_meal) as m4m").group("date(ticket_close_time)")
		
		if restaurant == "p42"
			case granularity
			when "day"
				details_tbl = P42::TicketItem.find_by_sql("SELECT to_char(t1.date, 'Mon DD, YYYY') AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS m4m
					FROM p42_ticket_items 
					WHERE pos_revenue_class_id != 15 AND pos_revenue_class_id != 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY CAST(ticket_close_time AS DATE)) t1
				LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS dym
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 15
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY CAST(ticket_close_time AS DATE)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS apparel
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY CAST(ticket_close_time AS DATE)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT CAST(deposit_date AS DATE) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY CAST(deposit_date AS DATE)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT CAST(deposit_date AS DATE) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY CAST(deposit_date AS DATE)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS total
					FROM p42_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY CAST(ticket_close_time AS DATE)) t5
				ON t1.date = t5.date")	
			when "month"
				details_tbl = P42::TicketItem.find_by_sql("SELECT to_char(t1.date, 'Mon, YYYY') AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS m4m
					FROM p42_ticket_items 
					WHERE pos_revenue_class_id != 15 AND pos_revenue_class_id != 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t1
				LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS dym
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 15
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS apparel
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT DATE_TRUNC('month', deposit_date) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY DATE_TRUNC('month', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('month', deposit_date) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY DATE_TRUNC('month', deposit_date)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS total
					FROM p42_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t5
				ON t1.date = t5.date")
			when "quarter"
				details_tbl = P42::TicketItem.find_by_sql("SELECT ('Q' || to_char(t1.date, 'Q YYYY')) AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS m4m
					FROM p42_ticket_items 
					WHERE pos_revenue_class_id != 15 AND pos_revenue_class_id != 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t1
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS dym
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 15
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS apparel
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', deposit_date) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY DATE_TRUNC('quarter', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', deposit_date) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY DATE_TRUNC('quarter', deposit_date)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS total
					FROM p42_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t5
				ON t1.date = t5.date")
			when "year"
				details_tbl = P42::TicketItem.find_by_sql("SELECT to_char(t1.date, 'YYYY') AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS m4m
					FROM p42_ticket_items 
					WHERE pos_revenue_class_id != 15 AND pos_revenue_class_id != 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t1
				LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS dym
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 15
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS apparel
					FROM p42_ticket_items
					WHERE pos_revenue_class_id = 18
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT DATE_TRUNC('year', deposit_date) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY DATE_TRUNC('year', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('year', deposit_date) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 1
					GROUP BY DATE_TRUNC('year', deposit_date)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS total
					FROM p42_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t5
				ON t1.date = t5.date")			
			end
		elsif restaurant == "tacos"
			case granularity
			when "day"
				details_tbl = Tacos::TicketItem.find_by_sql("SELECT to_char(t1.date, 'Mon DD, YYYY') AS date, 
					t1.m4m, COALESCE(t2.dym, 0) AS dym, 
					COALESCE(t3.apparel, 0) AS apparel, 
					COALESCE(t4.tip_jar,0) AS tip_jar, 
					COALESCE(t6.one_time,0) AS one_time,
					( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS m4m
					FROM tacos_ticket_items 
					WHERE pos_category_id IN (1, 2, 3, 4, 5, 15)
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY CAST(ticket_close_time AS DATE)) t1
				LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS dym
					FROM tacos_ticket_items
					WHERE menu_item_id = 7000
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY CAST(ticket_close_time AS DATE)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS apparel
					FROM tacos_ticket_items
					WHERE pos_category_id = 11
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY CAST(ticket_close_time AS DATE)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT CAST(deposit_date AS DATE) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY CAST(deposit_date AS DATE)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT CAST(deposit_date AS DATE) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY CAST(deposit_date AS DATE)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS total
					FROM tacos_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY CAST(ticket_close_time AS DATE)) t5
				ON t1.date = t5.date")	
			when "month"
				details_tbl = Tacos::TicketItem.find_by_sql("SELECT to_char(t1.date, 'Mon, YYYY') AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS m4m
					FROM tacos_ticket_items 
					WHERE pos_category_id IN (1, 2, 3, 4, 5, 15)
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t1
				LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS dym
					FROM tacos_ticket_items
					WHERE menu_item_id = 7000
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS apparel
					FROM tacos_ticket_items
					WHERE pos_category_id = 11
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT DATE_TRUNC('month', deposit_date) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY DATE_TRUNC('month', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('month', deposit_date) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY DATE_TRUNC('month', deposit_date)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS total
					FROM tacos_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('month', ticket_close_time)) t5
				ON t1.date = t5.date")
			when "quarter"
				details_tbl = Tacos::TicketItem.find_by_sql("SELECT ('Q' || to_char(t1.date, 'Q YYYY')) AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS m4m
					FROM tacos_ticket_items 
					WHERE pos_category_id IN (1, 2, 3, 4, 5, 15)
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t1
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS dym
					FROM tacos_ticket_items
					WHERE menu_item_id = 7000
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS apparel
					FROM tacos_ticket_items
					WHERE pos_category_id = 11
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', deposit_date) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY DATE_TRUNC('quarter', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', deposit_date) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY DATE_TRUNC('quarter', deposit_date)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS total
					FROM tacos_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t5
				ON t1.date = t5.date")
			when "year"
				details_tbl = Tacos::TicketItem.find_by_sql("SELECT to_char(t1.date, 'YYYY') AS date, 
						t1.m4m, COALESCE(t2.dym, 0) AS dym, 
						COALESCE(t3.apparel, 0) AS apparel, 
						COALESCE(t4.tip_jar,0) AS tip_jar, 
						COALESCE(t6.one_time,0) AS one_time,
						( t5.total + COALESCE(t4.tip_jar,0) + COALESCE(t6.one_time,0) ) AS total 
				FROM 
					(SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS m4m
					FROM tacos_ticket_items 
					WHERE pos_category_id IN (1, 2, 3, 4, 5, 15)
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t1
				LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS dym
					FROM tacos_ticket_items
					WHERE menu_item_id = 7000
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t2
				ON t1.date = t2.date
				LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS apparel
					FROM tacos_ticket_items
					WHERE pos_category_id = 11
					AND ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t3
				ON t1.date = t3.date
				LEFT JOIN (SELECT DATE_TRUNC('year', deposit_date) as date, SUM(meals) AS tip_jar
					FROM tip_jar_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY DATE_TRUNC('year', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('year', deposit_date) as date, SUM(meals) AS one_time
					FROM one_time_donations
					WHERE deposit_date between '#{start_date}' AND '#{end_date}'
					AND restaurant_id = 2
					GROUP BY DATE_TRUNC('year', deposit_date)) t6
				ON t1.date = t6.date
				LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS total
					FROM tacos_ticket_items
					WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
					AND (void IS NULL OR void != 'TRUE')
					GROUP BY DATE_TRUNC('year', ticket_close_time)) t5
				ON t1.date = t5.date")	
			end
		end


		details_tbl
	end
end	