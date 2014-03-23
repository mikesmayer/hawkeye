class P42::Discount < ActiveRecord::Base


  def self.sync_discounts
  	initialize_soap
  	discount_response = get_discounts

  	discount_response.each do |discount|
  		id = discount[:type_id]
  		name = discount[:name]
  		active = discount[:active]

  		P42::Discount.find_or_update_by_id(id, name, active)
  	end
  	return "Sync completed successfully"
  end

  private
  def self.initialize_soap
    @client = Savon.client(wsdl: Restaurant.find(1).soap_url, endpoint: Restaurant.find(1).soap_endpoint)
  end

  def self.get_discounts
  	response = @client.call(:get_all_discount_list)
  	response.body[:get_all_discount_list_response][:get_all_discount_list_result][:discount]
  end

  def self.find_or_update_by_id(id, name, active)
  	discount = P42::Discount.find_by_id(id)
  	if discount.nil?
  		discount = P42::Discount.create(:id => id, :name => name, :active => active)
  	else
  		discount = discount.update_attributes(:name => name, :active => active)
  	end
  	discount
  end
end

