class ItemSaleDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
  # include AjaxDatatablesRails::Extensions::Kaminari
    include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    
    @sortable_columns ||= ['p42_ticket_items.ticket_close_time']
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    @searchable_columns ||= []
  end

  private

  def data
    records.map do |record|
      [
        record.ticket_close_time.strftime("%-m-%e-%Y %l:%M"),
        record.menu_item.name,
        record.menu_item_group.name,
        record.quantity,
        record.net_price,
        record.meal_for_meal
      ]
    end
  end

  def get_raw_records
    start_date = "#{self.options[:start_date]}T00:00:00"
    end_date = "#{self.options[:end_date]}T23:59:50"
    #start_date = '2000-01-01T00:00:00'
    #end_date = '2100-01-01T23:59:59'

    if self.options[:restaurant] == "p42"
      P42::TicketItem.where("ticket_close_time between ? AND ?", start_date, end_date)
    elsif self.options[:tacos] == "tacos"
      P42::TicketItem.where("ticket_close_time between ? AND ?", start_date, end_date)

    end
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
