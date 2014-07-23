require 'csv'
require 'json'

class P42::TicketItem < ActiveRecord::Base



	# Updates the meal count for the ticket item
	def update_meal_count
		modifier = P42::MealCountRule.get_multiplier(menu_item_id, ticket_close_time)
		self.update_attributes( :meal_for_meal => (modifier * quantity) )
	end




	##
	#  Only using my @pitza42 account. It's the owner of the P42 Reports Folder and
	#  the Tacos Reports folder. This method looks up the refresh token for that account and
	#  creates a new client and drive
	#
	def self.setup_client
		@tyler_p42 = User.find_by email: 'tyler@pitza42.com'

		puts @tyler_p42.inspect 

		@client = Google::APIClient.new(
			application_name: "TestApp",
			application_version: "1.0.0"
		)
		@client.authorization.client_id = ENV['GOOGLE_AUTH_CLIENT_ID']
		@client.authorization.client_secret = ENV['GOOGLE_AUTH_CLIENT_SECRET']
		@client.authorization.grant_type = 'refresh_token'
		@client.authorization.refresh_token = @tyler_p42.refresh_token

		#puts YAML::dump(@client.authorization)

		@client.authorization.fetch_access_token!
		@client.authorization
		
		puts YAML::dump(@client.authorization)

		@drive = @client.discovered_api('drive', 'v2')

	end

	def self.get_file_id_list(folderId)
		result = Array.new
		page_token = nil

		begin
			parameters = {'folderId' => folderId}
			if page_token.to_s != ''
			  parameters['pageToken'] = page_token
			end
			api_result = @client.execute(
			  :api_method => @drive.children.list,
			  :parameters => parameters)
			if api_result.status == 200
			  children = api_result.data

			  file_details = Hash.new
			  children.items.each do |item|
			  	#puts item.id
			  	#puts item['title']
			  	#file_details = { "id" => item['id'], "title" => "empty"}
			  	#result << file_details
			  	result << item['id']
			  end
			  


			  page_token = children.next_page_token
			else
			  puts "An error occurred: #{result.data['error']['message']}"
			  page_token = nil
			end
		end while page_token.to_s != ''
		result
	end

	def self.get_file_list
		setup_client
		result = Array.new
		
		# This folder id is for P42 Reports folder in Drive
		id_list = get_file_id_list('0B3s566IfxmitNVcwTE9rY0JkYmM')

		id_list.each do |id|
			api_result = @client.execute(
			  :api_method => @drive.files.get,
			  :parameters => { 'fileId' => id})
			if api_result.status == 200
			  file = api_result.data
			  puts file.title
			  puts YAML::dump(file)
			  


			  


		  	result << { "id" => file.id, 
		  				"title" => file.title }
			  

			  
			else
			  puts "An error occurred: #{result.data['error']['message']}"
			end
		end
		result
	end

	def self.save_file_to_local(file_id)
		ret_val = Hash.new

		api_result = @client.execute(
			  :api_method => @drive.files.get,
			  :parameters => { 'fileId' => file_id})
		if api_result.status == 200
		  file = api_result.data
		  if file.download_url
		    file_contents = @client.execute(:uri => file.download_url)
		    if file_contents.status == 200
		       
		       body = file_contents.body
		       title = file.title
		       
		       #name = "item_sales.csv"
		       #directory = "public/images/upload"

		    else
		      puts "An error occurred: #{result.data['error']['message']}"
		    end  
		  else
		    # The file doesn't have any content stored on Drive.
		  end
		  
		else
		  puts "An error occurred: #{result.data['error']['message']}"
		end



		ret_val = {"body" => body, "title" => title}	    
	end


	def self.get_csv(file_id)

		api_result = @client.execute(
			:api_method => @drive.files.get,
			:parameters => { 'fileId' => file_id})

		#Get file
		if api_result.status == 200
			file = api_result.data 

			#Download file
			if file.download_url

				file_contents = @client.execute(:uri => file.download_url)
				if file_contents.status == 200
					body = file_contents.body
					title = file.title
				end

			else
				#File has no contents on drive therefore not download_url
			end

		else
			#status was not 200
		end

		#body is a string containing the contents of the downloaded file
		body
	end


	def self.parse_csv(file_id)
		if @drive.nil?
			setup_client
		end
		file_body = self.get_csv(file_id)
		csv_rows = Array.new

		file_body = file_body.strip

		#csv = CSV.parse(file_body, {:headers => true, :col_sep => ";", :quote_char => "|"})

		csv = CSV.new(file_body, :headers => true, :header_converters => :symbol, :converters => :all, :col_sep => ";", :quote_char => "|")
		csv = csv.to_a.map {|row| row.to_hash }

		
		items = P42::TicketItem.add_tickets_to_db(csv)
=begin
		csv.each do |row|
			puts row.to_s

			csv_rows << row
		end
=end

		"Successfully parsed csv - #{items} added"
	end

	def self.add_tickets_to_db(csv_body)
		items = 0

		csv_body.each do |row|
			if (row[:ticket_item_id].is_a? Numeric)
				
				#Discount total null check
				if row[:discount_total] == "NULL"
					row[:discount_total] = 0
				end

				#customer id check
				if row[:customer_original_id] == "NULL"
					row[:customer_original_id] = 0
				end

				P42::TicketItem.find_or_update_by_ticket_item_id(
					row[:ticket_item_id],
					row[:ticket_id],
					row[:menu_item_id],
					row[:i_price_category_id],
					row[:i_revenue_class],
					row[:customer_original_id],
					row[:quantity],
					row[:net_price],
					row[:discount_total],
					row[:item_menu_price],					
					row[:choice_additions_total],				
					row[:ticket_close_time],					
					-1)
				items += 1
			end
			
		end
		items
	end

	### NOT currently used ###
	def replace_nulls(csv_body)
		csv_body.each do |row|
			#Discount total null check
			if row[:discount_total] == "NULL"
				row[:discount_total] = 0
			end

			#customer id check
			if row[:customer_original_id] == "NULL"
				row[:customer_original_id] = 0
			end
		end
		csv_body
	end

	def self.find_or_update_by_ticket_item_id(pos_ticket_item_id, pos_ticket_id, menu_item_id, pos_category_id, pos_revenue_class_id,
	 customer_original_id, quantity, net_price, discount_total, item_menu_price, choice_additions_total, ticket_close_time, meal_for_meal)
  	
		ticket_item = P42::TicketItem.find_by_pos_ticket_item_id(pos_ticket_item_id)
		if ticket_item.nil?
			ticket_item = P42::TicketItem.create(:pos_ticket_item_id => pos_ticket_item_id, :pos_ticket_id => pos_ticket_id, 
				:menu_item_id => menu_item_id, :pos_category_id => pos_category_id, :pos_revenue_class_id => pos_revenue_class_id,
				:customer_original_id => customer_original_id, :quantity => quantity, :net_price => net_price, :discount_total => discount_total,
				:item_menu_price => item_menu_price, :choice_additions_total => choice_additions_total, :ticket_close_time => ticket_close_time,
				:meal_for_meal => meal_for_meal)			
		else
			ticket_item.update_attributes(:pos_ticket_id => pos_ticket_id, 
				:menu_item_id => menu_item_id, :pos_category_id => pos_category_id, :pos_revenue_class_id => pos_revenue_class_id,
				:customer_original_id => customer_original_id, :quantity => quantity, :net_price => net_price, :discount_total => discount_total,
				:item_menu_price => item_menu_price, :choice_additions_total => choice_additions_total, :ticket_close_time => ticket_close_time,
				:meal_for_meal => meal_for_meal)
		end
		ticket_item.update_meal_count
		ticket_item
	end


	# This method is used to update the meal_for_meal field for every ticket item in the given
	# date range - it will return the ticket stats for the date range for display 
	def self.update_all_tickets_meal_count(start_date, end_date)
		all_items = P42::TicketItem.where(:ticket_close_time => start_date.beginning_of_day..end_date.end_of_day)
		ticket_item_count = all_items.count
		#total_meals = 0
		all_items.each do |item|

			item.update_meal_count
		end
		
		total_meals = all_items.sum(:meal_for_meal)
		{ :total_meals => total_meals, :ticket_item_count => ticket_item_count }
	end


end
