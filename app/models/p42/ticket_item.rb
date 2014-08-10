require 'csv'
require 'json'

class P42::TicketItem < ActiveRecord::Base
	belongs_to :menu_item_group, :foreign_key => :pos_category_id
	belongs_to :menu_item


	# Updates the meal count for the ticket item
	def update_meal_count
		modifier = P42::MealCountRule.get_multiplier(menu_item_id, ticket_close_time)
		self.update_attributes( :meal_for_meal => (modifier * quantity) )
	end


=begin
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
=end



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
  	
  		  results = { :action => '', :obj_id => nil, :error => nil }


		ticket_item = P42::TicketItem.find_by_pos_ticket_item_id(pos_ticket_item_id)
		if ticket_item.nil?
			
			ticket_item = P42::TicketItem.create(:pos_ticket_item_id => pos_ticket_item_id, :pos_ticket_id => pos_ticket_id, 
				:menu_item_id => menu_item_id, :pos_category_id => pos_category_id, :pos_revenue_class_id => pos_revenue_class_id,
				:customer_original_id => customer_original_id, :quantity => quantity, :net_price => net_price, :discount_total => discount_total,
				:item_menu_price => item_menu_price, :choice_additions_total => choice_additions_total, :ticket_close_time => ticket_close_time,
				:meal_for_meal => meal_for_meal)	

			if ticket_item.errors.count > 0 
				results[:error] = "Failed to create p42 ticket item."
			else
				results[:action] = "create"
			end
			
		else
			
			unless ticket_item.update_attributes(:pos_ticket_id => pos_ticket_id, 
				:menu_item_id => menu_item_id, :pos_category_id => pos_category_id, :pos_revenue_class_id => pos_revenue_class_id,
				:customer_original_id => customer_original_id, :quantity => quantity, :net_price => net_price, :discount_total => discount_total,
				:item_menu_price => item_menu_price, :choice_additions_total => choice_additions_total, :ticket_close_time => ticket_close_time,
				:meal_for_meal => meal_for_meal)

				results[:error] = "Failed to update p42 ticket item #{ticket_item.id}"
			end
			results[:action] = "update"
		end
		ticket_item.update_meal_count
		results[:obj_id] = ticket_item.id
		results
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
