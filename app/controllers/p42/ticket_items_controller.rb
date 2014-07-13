class P42::TicketItemsController < ApplicationController
  before_action :set_p42_ticket_item, only: [:show, :edit, :update, :destroy]

  # GET /p42/ticket_items
  # GET /p42/ticket_items.json
  def index
    unless params[:view_start_date].nil? || params[:view_end_date].nil? || params[:view_start_date].empty? || params[:view_end_date].empty?
      start_date = DateTime.parse(params[:view_start_date])
      end_date = DateTime.parse(params[:view_end_date])
      @p42_ticket_items = P42::TicketItem.where(:ticket_close_time => (start_date)..(end_date + 1.day)).order('pos_ticket_id')
      @meal_count = P42::TicketItem.where("meal_for_meal > 0").sum(:meal_for_meal)
    end    
  end

  def files
    ###
  end

  # GET /p42/ticket_items/1
  # GET /p42/ticket_items/1.json
  def show
  end

  # GET /p42/ticket_items/new
  def new
    @p42_ticket_item = P42::TicketItem.new
  end

  # GET /p42/ticket_items/1/edit
  def edit
  end

  # POST /p42/ticket_items
  # POST /p42/ticket_items.json
  def create
    @p42_ticket_item = P42::TicketItem.new(p42_ticket_item_params)

    respond_to do |format|
      if @p42_ticket_item.save
        format.html { redirect_to @p42_ticket_item, notice: 'Ticket item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_ticket_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_ticket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/ticket_items/1
  # PATCH/PUT /p42/ticket_items/1.json
  def update
    respond_to do |format|
      if @p42_ticket_item.update(p42_ticket_item_params)
        format.html { redirect_to @p42_ticket_item, notice: 'Ticket item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_ticket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/ticket_items/1
  # DELETE /p42/ticket_items/1.json
  def destroy
    @p42_ticket_item.destroy
    respond_to do |format|
      format.html { redirect_to p42_ticket_items_url }
      format.json { head :no_content }
    end
  end

=begin
  def save_file_to_local
    file = P42::TicketItem.save_file_to_local(params[:file_id])
    
    name = file['title']
    directory = "public/p42_files"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(file['body']) }
    flash[:notice] = "File uploaded"
    redirect_to "/p42/ticket_items/files"
  end
=end

  def calculate_meals
    start_date = DateTime.parse(params[:meal_start_date])
    end_date = DateTime.parse(params[:meal_end_date])

    @results = P42::TicketItem.update_all_tickets_meal_count(start_date, end_date)

    respond_to do |format|
      format.js { render action: 'calculate_meals' }
    end
  end

  def parse_csv    
    @results = P42::TicketItem.parse_csv(params[:file_id])
    flash[:notice] = @results
  end


  def file_list
    @file_list = P42::TicketItem.get_file_list
    render :layout => false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_ticket_item
      @p42_ticket_item = P42::TicketItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_ticket_item_params
      params.require(:p42_ticket_item).permit(:ticket_item_id, :ticket_id, :menu_item_id, :category_id, :revenue_class_id, :customer_original_id, :quantity, :net_price, :discount_total, :item_menu_price, :choice_additions_total, :ticket_close_time)
    end
end
