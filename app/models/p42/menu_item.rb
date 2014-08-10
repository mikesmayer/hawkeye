class P42::MenuItem < ActiveRecord::Base
	has_many :meal_count_rules, :dependent => :destroy
	belongs_to :menu_item_group
	belongs_to :revenue_group
	belongs_to :ticket_items



  #after_create :set_default_meal_modifier
  #after_save :update_meal_check






  class << self
    def sync_menu_items
      initialize_soap
      
      menu_item_response = get_menu_items
      
      menu_item_response.each do |menu_item|
      id = menu_item[:id]
      name = menu_item[:item_name]
      menu_item_group_id = menu_item[:price_cat_id]
      if menu_item_group_id.nil?  || menu_item_group_id.to_i < 0 
        menu_item_group_id = 0
      end
      revenue_class_id = menu_item[:revenue_class_id]
      gross_price = menu_item[:price].to_f
      
      P42::MenuItem.find_or_update_by_id(id, name, menu_item_group_id, revenue_class_id, gross_price)
      end
    end
    handle_asynchronously :sync_menu_items
  end


  def get_all_associated_ticket_items
    ticket_ids = Array.new
    self.ticket_items.all.each do |item|
      ticket_ids << item.ticket_id
    end
    ticket_ids.uniq
  end

=begin
  # determine if meal setting have changed and thus meal counts need to be updated
  def update_meal_check
    if self.count_meal_changed? || self.count_meal_modifier_changed?
      update_meal_counts
    end    
  end
=end

=begin
  #checks to see if the item group it belongs to has a default meal modifier set and sets its modifier if necessary
  def set_default_meal_modifier    
    meal_num = self.menu_item_group.try(:default_meal_modifier)
    if meal_num.nil?
      self.count_meal = false
      self.count_meal_modifier = 0
    else
      meal_num.to_i
      if meal_num == 0
        self.count_meal = false
        self.count_meal_modifier = meal_num
      else
        self.count_meal = true
        self.count_meal_modifier = meal_num
      end
      self.save
    end

  end
=end

  def update_meal_counts
    #customer_ids = Array.new
    ticket_items = get_all_associated_ticket_items
    ticket_items.each do |ticket_item|      
      t = P42::TicketItem.find(ticket_item)
      t.delay.recalculate_meal_numbers
      #unless t.customer_id.nil?
      #  customer_ids << t.customer_id.to_i
      #end      
    end
    customer_ids.uniq!
    #raise customer_ids.inspect
    customer_ids.each do |cust|
      logger.debug cust.inspect
      c = Customer.find_by_original_pos_id(cust)
      logger.debug c.inspect
      c.delay.update_meal_and_visit_total
    end
  end
  handle_asynchronously :update_meal_counts




  private
  def self.initialize_soap
    @client = Savon.client(wsdl: Restaurant.find(1).soap_url, endpoint: Restaurant.find(1).soap_endpoint)
  end

  def self.get_menu_items
    response = @client.call(:get_all_menu_items)
    response.body[:get_all_menu_items_response][:get_all_menu_items_result][:menu_item]
  end
  
  def self.find_or_update_by_id(id, name, menu_item_group_id, revenue_class_id, gross_price)
    results = { :action => '', :obj_id => nil, :error => nil }

  	menu_item = P42::MenuItem.find_by_id(id)
  	if menu_item.nil?
  		
      unless menu_item = P42::MenuItem.create(:id => id, :name => name, :menu_item_group_id => menu_item_group_id, 
  			:revenue_group_id => revenue_class_id, :gross_price => gross_price)
        
        results[:error] = "Failed to create p42 menu item."
        
      end
      MenuItemMailer.menu_item_added(menu_item, "p42").deliver
      results[:action] = "create"
  	else
  		
      unless menu_item.update_attributes(:name => name, :menu_item_group_id => menu_item_group_id, 
  			:revenue_group_id => revenue_class_id, :gross_price => gross_price)

        results[:error] = "Failed to update p42 menu item #{menu_item.id}"
      end
      results[:action] = "update"
  	end
  	results[:obj_id] = menu_item.id
    results
  end
end
