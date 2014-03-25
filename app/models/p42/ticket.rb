class P42::Ticket < ActiveRecord::Base
 has_many :ticket_items, :dependent => :destroy
 has_many :discount_items, :dependent => :destroy
 #belongs_to :customer, :class_name => 'Customer', :foreign_key => "pos_id"

 validates :pos_ticket_id, :uniqueness => true

 class << self
	def sync_tickets(start_date, end_date)
	    initialize_soap
	    
	   	ticket_header_response = get_ticket_headers(start_date, end_date)

	   	#logger.debug ticket_header_response
	   	ticket_count = 0
	   	unless ticket_header_response.nil?
	   		@customer_id_array = Array.new
	   		ticket_header_response.each do |ticket|
	   			# make sure to only add a ticket if it was not voided
	   			if(ticket[:void_id] == "-1")
	   				#P42::Ticket.delay.get_ticket(ticket[:id])
	   				P42::Ticket.get_ticket(ticket[:id])
	   				ticket_count += 1
	   			end
	   		end
	   		#customer_update(@customer_id_array)
	   	end

	   	return "#{ticket_count} tickets were added to the database."
	    #JobLog.create(:job_name => 'sync_tickets', :result => "Successful sync. #{ticket_count} tickets were added. Start date: #{start_date} - End Date: #{end_date} ")
	  end
	  #handle_asynchronously :sync_tickets
  end
  

  def self.find_or_update_by_pos_ticket_id(pos_ticket_id, customer_id, ticket_open_time, 
		ticket_close_time, customer_phone, discount_total, net_price_total, gross_price_total)
  	ticket = P42::Ticket.find_by_pos_ticket_id(pos_ticket_id)
  	if ticket.nil?
  		ticket = P42::Ticket.create(:pos_ticket_id => pos_ticket_id, :customer_id => customer_id, :ticket_open_time => ticket_open_time, 
		:ticket_close_time => ticket_close_time, :customer_phone => customer_phone, 
		:discount_total => discount_total, :net_price => net_price_total, :gross_price => gross_price_total)
  	else
  		ticket.update_attributes(:customer_id => customer_id, :ticket_open_time => ticket_open_time, 
		:ticket_close_time => ticket_close_time, :customer_phone => customer_phone, 
		:discount_total => discount_total, :net_price => net_price_total, :gross_price => gross_price_total)
  	end
  	ticket
  end


  def recalculate_meal_numbers
  	# Customer meal number recalculation called from the menu_item model where this method is called
  	meal_num = 0
  	self.ticket_items.each do |item|
  		#raise item.inspect
  		current_meal_num = P42::Ticket.get_meal_numbers(item.menu_item_id, item.menu_item_group_id, item.item_qty, self.ticket_close_time)
  		item.meal_for_meal = current_meal_num
  		meal_num += current_meal_num
  		item.save
  	end  	
  	self.meal_for_meal = meal_num
  	self.save
  end




  private
  def self.initialize_soap
    @client = Savon.client(wsdl: Restaurant.find(1).soap_url, endpoint: Restaurant.find(1).soap_endpoint)
  end




  def self.get_ticket_headers(start_date, end_date)
    response = @client.call(:get_ticket_headers) do 
      message dtStart: start_date, dtEnd: end_date, lUserID: 0, bRealHours: 'false', bAllUsers: 'true'
    end
    response.body[:get_ticket_headers_response][:get_ticket_headers_result][:ticket]
  end



  def self.get_ticket(id)
  	# start with a discount clear - have to clear out discounts associated with this 
  	# ticket because the API provides no way to uniquely id a ticket's given discounts
  	# So I have to destroy all the discounts associated with the ticket and recreate them
  	# since an update isn't possible 
  	clear_discounts(id)

	ticket_result = @client.call(:get_ticket) do
		message id: id
	end  	

	ticket_contents = ticket_result.body[:get_ticket_response][:get_ticket_result]
	
	customer_id = ticket_contents[:customer][:id]
	customer_phone = ticket_contents[:customer][:phone]
	# wsCover can be either an array or an object
	ticket_items = ticket_contents[:covers][:ws_cover]

	# add customer id to array so that each customer's meal count will be updated after 
	# all the tickets are added
	unless customer_id.nil?
		@customer_id_array << customer_id.to_i
	end	

	## CONVERT time to DateTime with the correct offset ##

	ticket_open_time = ticket_contents[:create_time]
	ticket_close_time = ticket_contents[:close_time]

	logger.debug "ticket open time:"
	logger.debug ticket_open_time.inspect

	#ticket_open_time = DateTime.parse(ticket_open_time.to_s)
	#ticket_open_time = Time.strptime(ticket_open_time.to_s,'%a, %d %b %Y %H:%M:%S %z').in_time_zone(Time.zone)
	ticket_open_time = Time.parse(ticket_open_time.to_s).in_time_zone(Time.zone)

	logger.debug "ticket open time 2:"
	logger.debug ticket_open_time.inspect



	discount_total = ticket_contents[:discount_total]	
	net_price_total = ((ticket_contents[:total].to_f) - (ticket_contents[:tax_total].to_f))
	gross_price_total = (net_price_total.to_f + discount_total.to_f)
	

	current_ticket = P42::Ticket.find_or_update_by_pos_ticket_id(id, customer_id, ticket_open_time, 
		ticket_close_time, customer_phone, discount_total, net_price_total, gross_price_total)

	if ticket_items.kind_of?(Array)
		#auto_discount_total = 0
		#manual_discount_total = 0
		#gross_price_total = ticket_contents[:subtotal]
		#net_price_total = ticket_contents[:total]		
		#meal_for_meal_total = 0

		#logger.debug "Ticket: "
		#logger.debug id
		ticket_items.each do |ticket_item|
			unless ticket_item[:ticket_items].nil?
				items = ticket_item[:ticket_items][:ws_menu_item]			
				ticket_attr_hash = array_add_ticket_item(id, items, current_ticket.id, ticket_close_time)
				
				#logger.debug "ticket item:"
				#logger.debug ticket_attr_hash.inspect

				#auto_discount_total += ticket_attr_hash[0]["auto_discount"].to_f
				#manual_discount_total += ticket_attr_hash[0]["manual_discount"].to_f
				#gross_price_total += ticket_attr_hash[0]["gross_price"].to_f
				#net_price_total += ticket_attr_hash[0]["net_price"].to_f
				#meal_for_meal_total += ticket_attr_hash[0]["meal_for_meal"].to_i
			end
		end	

		cur_tick = P42::Ticket.find(current_ticket.id)
		mfm_total = cur_tick.ticket_items.sum(:meal_for_meal)
		man_dis_total = cur_tick.ticket_items.sum(:manual_discount)
		auto_dis_total = cur_tick.ticket_items.sum(:auto_discount)

		cur_tick.update_attributes(:manual_discount => man_dis_total, 
			:auto_discount => auto_dis_total, :meal_for_meal => mfm_total)
	elsif ticket_items.kind_of?(Object)
		unless ticket_items[:ticket_items].nil?
			ticket_items = ticket_items[:ticket_items][:ws_menu_item]		
			add_ticket_item(id, ticket_items, current_ticket.id, ticket_close_time)
		end		
	end
  end




  def self.add_ticket_item(pos_ticket_id, ticket_items, current_ticket_id, ticket_close_time)  	
  	# have to test to see if the ticket_items variable is an object or an array 
  	# - it will be an object if there is only one item for the given ticket
	if !ticket_items.nil? && ticket_items.kind_of?(Array) 
		logger.debug "Array - Ticket_ID:"
		logger.debug current_ticket_id

		auto_discount_total = 0
		manual_discount_total = 0
		#gross_price_total = 0
		#net_price_total = 0
		meal_for_meal_total = 0

		ticket_items.each do |item|
			auto_discount = 0
			manual_discount = 0
			auto_apply = 0
			
			item_id = item[:id]
			net_price = item[:net_price]
			gross_price = item[:gross_price_with_auto]			
			ticket_item_id = item[:ticketitem_id]

			unless item[:discounts].nil?
				discounts = item[:discounts][:ws_discount]
				discount_amounts = get_discounts(discounts, pos_ticket_id, current_ticket_id, 
				ticket_item_id, ticket_close_time, item_id, gross_price)

				auto_discount = discount_amounts["auto"]
				manual_discount = discount_amounts["manual"]
			end			
			item_qty = item[:quantity]
			revenue_group_id = get_item_revenue_group(item_id)
			menu_item_group_id = get_menu_item_group(item_id)
			
			meal_for_meal = get_meal_numbers(item_id, menu_item_group_id, item_qty, ticket_close_time)
			meal_for_meal_total += meal_for_meal


			P42::TicketItem.find_or_update_by_ticket_item_id(ticket_item_id, pos_ticket_id, current_ticket_id, 
				item_id, net_price,	gross_price, manual_discount, auto_discount, item_qty, revenue_group_id, 
				menu_item_group_id, meal_for_meal)

			
			auto_discount_total += auto_discount
			manual_discount_total += manual_discount
			#gross_price_total += gross_price.to_f
			#net_price_total += net_price.to_f

			#logger.debug "Net Price for #{current_ticket_id}"
			#logger.debug net_price_total
		end
		P42::Ticket.find(current_ticket_id).update_attributes(:manual_discount => manual_discount_total, :auto_discount => auto_discount_total,
			:meal_for_meal => meal_for_meal_total)

	elsif !ticket_items.nil? && ticket_items.kind_of?(Object)

		auto_discount = 0
		manual_discount = 0
		auto_apply = 0

		item_id = ticket_items[:id]
		net_price = ticket_items[:net_price]
		gross_price = ticket_items[:gross_price_with_auto]
		ticket_item_id = ticket_items[:ticketitem_id]

		unless ticket_items[:discounts].nil?
			discounts = ticket_items[:discounts][:ws_discount]
			discount_amounts = get_discounts(discounts, pos_ticket_id, current_ticket_id, 
				ticket_item_id, ticket_close_time, item_id, gross_price)

			auto_discount = discount_amounts["auto"]
			manual_discount = discount_amounts["manual"]
		end		
		item_qty = ticket_items[:quantity]
		revenue_group_id = get_item_revenue_group(item_id)
		menu_item_group_id = get_menu_item_group(item_id)

		meal_for_meal = get_meal_numbers(item_id, menu_item_group_id, item_qty, ticket_close_time)


		P42::Ticket.find(current_ticket_id).update_attributes(:manual_discount => manual_discount, :auto_discount => auto_discount,
			:meal_for_meal => meal_for_meal)

		P42::TicketItem.find_or_update_by_ticket_item_id(ticket_item_id, pos_ticket_id, current_ticket_id, 
				item_id, net_price,	gross_price, manual_discount, auto_discount, item_qty, revenue_group_id, 
				menu_item_group_id, meal_for_meal)
	end
  end

  def self.array_add_ticket_item(pos_ticket_id, ticket_items, current_ticket_id, ticket_close_time)  	
  	ticket_attr = Hash.new
  	# have to test to see if the ticket_items variable is an object or an array 
  	# - it will be an object if there is only one item for the given ticket
	if !ticket_items.nil? && ticket_items.kind_of?(Array) 
		logger.debug "Array - Ticket_ID:"
		logger.debug current_ticket_id

		auto_discount_total = 0
		manual_discount_total = 0
		gross_price_total = 0
		net_price_total = 0
		meal_for_meal_total = 0

		ticket_items.each do |item|
			auto_discount = 0
			manual_discount = 0
			auto_apply = 0
			logger.debug "TEST::"
			logger.debug item.inspect

			item_id = item[:id]
			net_price = item[:net_price]
			gross_price = item[:gross_price_with_auto]
			ticket_item_id = item[:ticketitem_id]

			unless item[:discounts].nil?
				discounts = item[:discounts][:ws_discount]
				discount_amounts = get_discounts(discounts, pos_ticket_id, current_ticket_id, 
				ticket_item_id, ticket_close_time, item_id, gross_price)

				auto_discount = discount_amounts["auto"]
				manual_discount = discount_amounts["manual"]
			end			
			item_qty = item[:quantity]			
			revenue_group_id = get_item_revenue_group(item_id)
			menu_item_group_id = get_menu_item_group(item_id)
			
			meal_for_meal = get_meal_numbers(item_id, menu_item_group_id, item_qty, ticket_close_time)
			meal_for_meal_total += meal_for_meal


			P42::TicketItem.find_or_update_by_ticket_item_id(ticket_item_id, pos_ticket_id, current_ticket_id, 
				item_id, net_price,	gross_price, manual_discount, auto_discount, item_qty, revenue_group_id, 
				menu_item_group_id, meal_for_meal)

			
			auto_discount_total += auto_discount
			manual_discount_total += manual_discount
			gross_price_total += gross_price.to_f
			net_price_total += net_price.to_f

			#logger.debug "Net Price for #{current_ticket_id}"
			#logger.debug net_price_total
		end
		ticket_attr = ["manual_discount" => manual_discount_total, "auto_discount" => auto_discount_total, 
			"gross_price" => gross_price_total, "net_price" => net_price_total, "meal_for_meal" => meal_for_meal_total]

	elsif !ticket_items.nil? && ticket_items.kind_of?(Object)

		auto_discount = 0
		manual_discount = 0
		auto_apply = 0

		item_id = ticket_items[:id]
		net_price = ticket_items[:net_price]
		gross_price = ticket_items[:gross_price_with_auto]
		ticket_item_id = ticket_items[:ticketitem_id]
		unless ticket_items[:discounts].nil?
			discounts = ticket_items[:discounts][:ws_discount]
			discount_amounts = get_discounts(discounts, pos_ticket_id, current_ticket_id, 
				ticket_item_id, ticket_close_time, item_id, gross_price)

			auto_discount = discount_amounts["auto"]
			manual_discount = discount_amounts["manual"]
		end		
		item_qty = ticket_items[:quantity]		
		revenue_group_id = get_item_revenue_group(item_id)
		menu_item_group_id = get_menu_item_group(item_id)

		meal_for_meal = get_meal_numbers(item_id, menu_item_group_id, item_qty, ticket_close_time)


		ticket_attr = ["manual_discount" => manual_discount, "auto_discount" => auto_discount, 
			"gross_price" => gross_price, "net_price" => net_price, "meal_for_meal" => meal_for_meal]

		P42::TicketItem.find_or_update_by_ticket_item_id(ticket_item_id, pos_ticket_id, current_ticket_id, 
				item_id, net_price,	gross_price, manual_discount, auto_discount, item_qty, revenue_group_id, 
				menu_item_group_id, meal_for_meal)
	end
	ticket_attr
  end


  def self.get_discounts(discounts, pos_ticket_id, ticket_id, pos_ticket_item_id, ticket_close_time, menu_item_id, item_price)
  	auto_discount = 0
  	manual_discount = 0
  	# have to test to see if the discounts variable is an object or an array - 
  	# it will be an object if there is only one discount
	if !discounts.nil? && discounts.kind_of?(Array)
		discounts.each do |discount|
			reason_text = discount[:reason]
			discount_id = discount[:id]

			if discount[:autoapply]
				auto_discount += discount[:value].to_f
				individual_auto = discount[:value].to_f
				auto_apply = true
				P42::DiscountItem.create(:pos_ticket_id => pos_ticket_id, :ticket_id => ticket_id, 
					:pos_ticket_item_id => pos_ticket_item_id, :when => ticket_close_time, 
					:menu_item_id => menu_item_id, :ticket_item_price => item_price, 
					:discount_item_id => discount_id, :reason_text => reason_text, 
					:discount_amount => individual_auto, :auto_apply => auto_apply)
			else
				manual_discount += discount[:value].to_f
				individual_manual = discount[:value].to_f
				auto_apply = false
				P42::DiscountItem.create(:pos_ticket_id => pos_ticket_id, :ticket_id => ticket_id, 
					:pos_ticket_item_id => pos_ticket_item_id, :when => ticket_close_time, 
					:menu_item_id => menu_item_id, :ticket_item_price => item_price, 
					:discount_item_id => discount_id, :reason_text => reason_text, 
					:discount_amount => individual_manual, :auto_apply => auto_apply)
			end	

		end
	elsif !discounts.nil? && discounts.kind_of?(Object)
		reason_text = discounts[:reason]
		discount_id = discounts[:id]

		if discounts[:autoapply]
			auto_discount += discounts[:value].to_f
			individual_auto = discounts[:value].to_f
			auto_apply = true
			P42::DiscountItem.create(:pos_ticket_id => pos_ticket_id, :ticket_id => ticket_id, 
					:pos_ticket_item_id => pos_ticket_item_id, :when => ticket_close_time, 
					:menu_item_id => menu_item_id, :ticket_item_price => item_price, 
					:discount_item_id => discount_id, :reason_text => reason_text, 
					:discount_amount => individual_auto, :auto_apply => auto_apply)
		else
			manual_discount += discounts[:value].to_f
			individual_manual = discounts[:value].to_f
			auto_apply = false
			P42::DiscountItem.create(:pos_ticket_id => pos_ticket_id, :ticket_id => ticket_id, 
					:pos_ticket_item_id => pos_ticket_item_id, :when => ticket_close_time, 
					:menu_item_id => menu_item_id, :ticket_item_price => item_price, 
					:discount_item_id => discount_id, :reason_text => reason_text, 
					:discount_amount => individual_manual, :auto_apply => auto_apply)
		end				
	end
	Hash["auto" => auto_discount, "manual" => manual_discount]
  end

  def self.get_item_revenue_group(item_id)
  	P42::MenuItem.find(item_id).revenue_group_id
  end

  def self.get_menu_item_group(item_id)
  	P42::MenuItem.find(item_id).menu_item_group_id
  end

=begin
  def self.get_meal_numbers(item_id, item_group_id, item_qty, ticket_close_time)
  	item_qty = item_qty.to_i
  	item_id = item_id.to_i
  	meal_num = 0
  	if(item_group_id == 41 || item_group_id == 42	|| item_group_id == 43 || item_group_id == 40 || 
  		item_group_id == 52 || item_group_id == 53 || item_group_id == 54)
  		
  		meal_num = item_qty

  	elsif(item_id == 256)
  		# item 256 is Double your meal
  		meal_num = item_qty

  	elsif(item_id == 353)
  		# item 353 is a Raffle ticket
  		meal_num = (item_qty/0.22)

  	elsif(item_id == 358)
  		# item 358 is a Bike Jersey
  		meal_num = (item_qty * 30)

  	elsif(item_id == 369 || item_id == 370)
  		# item 369 and 370 are MP 2013 T-shirts
  		meal_num = (item_qty * 30)

  	elsif(item_id == 315 || item_id == 316 || item_id == 312 || item_id == 313 || item_id == 314)
  		# all of these item number are for MP 2012 T-shirts - meals were only included before price
  		# change on 04-20-2012
  		if ticket_close_time < '2012-04-20'
  			meal_num = (item_qty * 30)
  		end

  	elsif(item_id == 272 || item_id == 338 || item_id == 303 || item_id == 271 || item_id == 270 ||
  		 item_id == 273 || item_id == 302)
  		# all of the different t-shirt item numbers over time
  		meal_num = (item_qty*10)
  	end
  	meal_num.to_i
  end
=end

  def self.get_meal_numbers(item_id, item_group_id, item_qty, ticket_close_time)
  	item_qty = item_qty.to_f
  	item_id = item_id.to_i
  	meal_num = 0
  	item = P42::MenuItem.find_by_id(item_id)
  	ticket_close_time = ticket_close_time.to_date

  	# test if item is used for meal count
	if item.count_meal
		if item.count_meal_modifier.nil?
			meal_num = 0
		else
			meal_num = item_qty * item.count_meal_modifier
		end

	end
=begin

		# test if item is only counted between certain dates
		if item.count_meal_start.nil? && item.count_meal_end.nil?
			# checkt to see if the modifier it set (i.e. modifier of 10 for t-shirts)
			if item.count_meal_modifier.nil?
				meal_num = item_qty
			else
				meal_num = item_qty * item.count_meal_modifier
			end
		else
			# else - start date or end date are set for given item
			# if start date is nil - set it to beginning
			if item.count_meal_start.nil?
				item.count_meal_start = "2011-09-20"
				item.save				
			end

			# check to see if end date is set
			if item.count_meal_end.nil?
				end_date = Date.today
			else
				end_date = item.count_meal_end
			end

			if (item.count_meal_start..end_date).cover?(ticket_close_time)
				# checkt to see if the modifier it set (i.e. modifier of 10 for t-shirts)
				if item.count_meal_modifier.nil?
					meal_num = item_qty
				else
					meal_num = item_qty * item.count_meal_modifier
				end
			else
				#raise item.inspect
			end


		end
		
	end
=end
  	meal_num.to_f
  end


  def self.clear_discounts(pos_ticket_id)
  	discounts = P42::DiscountItem.find_all_by_pos_ticket_id(pos_ticket_id)
  	unless discounts.empty?
  		P42::DiscountItem.delete discounts.map { |d| d.id }
  	end
  end

  class << self
	def customer_update(customer_id_array)
	  	customer_id_array.each do |customer|
	  		c = Customer.find_by_original_pos_id(customer)
	  		c.update_meal_and_visit_total
	  	end
	  end
	  handle_asynchronously :customer_update
  end
end
