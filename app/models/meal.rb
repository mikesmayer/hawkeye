class Meal


	def self.details_to_csv(details_tbl)
		CSV.generate do |csv|
			csv << ["Date", "Meal4Meal", "Double", "Apparel", "Tips", "Total"]

			details_tbl.each do |row|
				csv << [row.date, row.m4m, row.dym, row.apparel, row.tip_jar, row.total]
			end
		end
	end


end	