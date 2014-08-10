class P42::MenuItemGroup < ActiveRecord::Base
	has_many :menu_items

	validates :default_meal_modifier, numericality: { only_integer: true }

  def self.sync_menu_item_groups
    initialize_soap
    
   	groups_response = get_menu_item_groups
   	
   	groups_response.each do |menu_item_group|
		id = menu_item_group[:id]
		name = menu_item_group[:description]		
		
		P42::MenuItemGroup.find_or_update_by_id(id, name)
   	end
   	return "Sync completed successfully"
  end


  private
  def self.initialize_soap
    @client = Savon.client(wsdl: Restaurant.find(1).soap_url, endpoint: Restaurant.find(1).soap_endpoint)
  end

  def self.get_menu_item_groups
    response = @client.call(:get_all_item_groups)
    response.body[:get_all_item_groups_response][:get_all_item_groups_result][:item_group]
  end
  
  def self.find_or_update_by_id(id, name)
    results = { :action => '', :obj_id => nil, :error => nil }

  	menu_item_group = P42::MenuItemGroup.find_by_id(id)
  	if menu_item_group.nil?
    	menu_item_group = P42::MenuItemGroup.create(:id => id, :name => name, :default_meal_modifier => 0)
      if menu_item_group.errors.count > 0
        results[:error] = "Failed to create p42 menu item group."
      else
        results[:action] = "create"
      end
  	else
  		unless menu_item_group.update_attributes(:name => name)
        results[:error] = "Failed to update p42 menu item group #{menu_item_group.id}"
      end
      results[:action] = "update"
  	end
  	  results[:obj_id] = menu_item_group.id
      results
  end
end
