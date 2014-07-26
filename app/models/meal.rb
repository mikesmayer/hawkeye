class Meal


	def self.details_to_csv(details_tbl)
		CSV.generate do |csv|
			csv << ["Date", "Meal4Meal", "Double", "Apparel", "Tips", "Total"]

			details_tbl.each do |row|
				csv << [row.date, row.m4m, row.dym, row.apparel, row.tip_jar, row.total]
			end
		end
	end

	def self.get_meal_totals(start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

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
			.sum(:meals)

		totals += tip_jar_total

		meal_nums = {:total => totals, :m4m => m4m_total, 
			:dym => dym_total, :apparel => apparel_total, :tip_jar => tip_jar_total}
		meal_nums.to_json
	end

	def self.get_month_breakdown(start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		P42::TicketItem.select("DATE_TRUNC('month', ticket_close_time) as month, sum(meal_for_meal) as total")
		.where("ticket_close_time between ? AND ?", start_date, end_date)
		.group("DATE_TRUNC('month', ticket_close_time)")
		.order("DATE_TRUNC('month', ticket_close_time) ASC")
	end

	def self.get_year_breakdown(start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"

		P42::TicketItem.select("DATE_TRUNC('year', ticket_close_time) as year, sum(meal_for_meal) as total")
		.where("ticket_close_time between ? AND ?", start_date, end_date)
		.group("DATE_TRUNC('year', ticket_close_time)")
		.order("DATE_TRUNC('year', ticket_close_time) ASC")
	end

	def self.get_meal_breakdown(granularity, start_date, end_date)
		start_date = start_date.to_s+"T00:00:00"
		end_date = end_date.to_s+"T23:59:59"
		#dates = P42::TicketItem.select("date(ticket_close_time) as date").group("date(ticket_close_time)")

		#P42::TicketItem.select("date(ticket_close_time) as date, sum(meal_for_meal) as m4m").group("date(ticket_close_time)")
		case granularity
		when "day"
			details_tbl = P42::TicketItem.find_by_sql("SELECT to_char(t1.date, 'Mon DD, YYYY') AS date, t1.m4m, COALESCE(t2.dym, 0) AS dym, COALESCE(t3.apparel, 0) AS apparel, COALESCE(t4.tip_jar,0) AS tip_jar, (t5.total + COALESCE(t4.tip_jar,0)) AS total FROM 
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
				GROUP BY CAST(deposit_date AS DATE)) t4
			ON t1.date = t4.date
			LEFT JOIN (SELECT CAST(ticket_close_time AS DATE) AS date, SUM(meal_for_meal) AS total
				FROM p42_ticket_items
				WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				GROUP BY CAST(ticket_close_time AS DATE)) t5
			ON t1.date = t5.date")	
		when "month"
			details_tbl = P42::TicketItem.find_by_sql("SELECT to_char(t1.date, 'Mon YYYY') AS date, t1.m4m, COALESCE(t2.dym, 0) AS dym, COALESCE(t3.apparel, 0) AS apparel, COALESCE(t4.tip_jar,0) AS tip_jar, (t5.total + COALESCE(t4.tip_jar,0)) AS total FROM 
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
				GROUP BY DATE_TRUNC('month', deposit_date)) t4
			ON t1.date = t4.date
			LEFT JOIN (SELECT DATE_TRUNC('month', ticket_close_time) as date, SUM(meal_for_meal) AS total
				FROM p42_ticket_items
				WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				GROUP BY DATE_TRUNC('month', ticket_close_time)) t5
			ON t1.date = t5.date")
		when "quarter"
			details_tbl = P42::TicketItem.find_by_sql("SELECT ('Q' || to_char(t1.date, 'Q YYYY')) AS date, t1.m4m, COALESCE(t2.dym, 0) AS dym, COALESCE(t3.apparel, 0) AS apparel, COALESCE(t4.tip_jar,0) AS tip_jar, (t5.total + COALESCE(t4.tip_jar,0)) AS total FROM 
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
				GROUP BY DATE_TRUNC('quarter', deposit_date)) t4
				ON t1.date = t4.date
				LEFT JOIN (SELECT DATE_TRUNC('quarter', ticket_close_time) as date, SUM(meal_for_meal) AS total
				FROM p42_ticket_items
				WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				GROUP BY DATE_TRUNC('quarter', ticket_close_time)) t5
				ON t1.date = t5.date")
		when "year"
			details_tbl = P42::TicketItem.find_by_sql("SELECT to_char(t1.date, 'YYYY') AS date, t1.m4m, COALESCE(t2.dym, 0) AS dym, COALESCE(t3.apparel, 0) AS apparel, COALESCE(t4.tip_jar,0) AS tip_jar, (t5.total + COALESCE(t4.tip_jar,0)) AS total FROM 
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
				GROUP BY DATE_TRUNC('year', deposit_date)) t4
			ON t1.date = t4.date
			LEFT JOIN (SELECT DATE_TRUNC('year', ticket_close_time) as date, SUM(meal_for_meal) AS total
				FROM p42_ticket_items
				WHERE ticket_close_time between '#{start_date}' AND '#{end_date}'
				GROUP BY DATE_TRUNC('year', ticket_close_time)) t5
			ON t1.date = t5.date")			
		end
		details_tbl
	end
end	