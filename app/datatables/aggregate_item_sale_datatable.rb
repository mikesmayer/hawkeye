class AggregateItemSaleDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
  # include AjaxDatatablesRails::Extensions::Kaminari
    include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    @sortable_columns ||= ['date']
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
        record.date,
        record.total_net_sales,
        record.total_discounts,
        record.meal_for_meal
      ]
    end
  end

  def get_raw_records
    granularity = self.options[:granularity]
    start_date = '2000-01-01'
    end_date = '2100-01-01'

    P42::TicketItem.select("DATE_TRUNC('month', ticket_close_time) as date, 
        SUM(net_price) as total_net_sales,
        SUM(discount_total) as total_discounts,
        SUM(meal_for_meal) as meal_for_meal")
    .where("ticket_close_time between ? AND ?", start_date, end_date)
    .group("DATE_TRUNC('month', ticket_close_time)")
    # insert query here
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
