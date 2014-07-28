class Tacos::TicketItemsController < ApplicationController
  before_action :set_tacos_ticket_item, only: [:show, :edit, :update, :destroy]

  # GET /tacos/ticket_items
  # GET /tacos/ticket_items.json
  def index
    @tacos_ticket_items = Tacos::TicketItem.all
  end

  # GET /tacos/ticket_items/1
  # GET /tacos/ticket_items/1.json
  def show
  end

  # GET /tacos/ticket_items/new
  def new
    @tacos_ticket_item = Tacos::TicketItem.new
  end

  # GET /tacos/ticket_items/1/edit
  def edit
  end

  # POST /tacos/ticket_items
  # POST /tacos/ticket_items.json
  def create
    @tacos_ticket_item = Tacos::TicketItem.new(tacos_ticket_item_params)

    respond_to do |format|
      if @tacos_ticket_item.save
        format.html { redirect_to @tacos_ticket_item, notice: 'Ticket item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tacos_ticket_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @tacos_ticket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tacos/ticket_items/1
  # PATCH/PUT /tacos/ticket_items/1.json
  def update
    respond_to do |format|
      if @tacos_ticket_item.update(tacos_ticket_item_params)
        format.html { redirect_to @tacos_ticket_item, notice: 'Ticket item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tacos_ticket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tacos/ticket_items/1
  # DELETE /tacos/ticket_items/1.json
  def destroy
    @tacos_ticket_item.destroy
    respond_to do |format|
      format.html { redirect_to tacos_ticket_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tacos_ticket_item
      @tacos_ticket_item = Tacos::TicketItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tacos_ticket_item_params
      params.require(:tacos_ticket_item).permit(:pos_ticket_item_id, :pos_ticket_id, :menu_item_id, :pos_category_id, :pos_revenue_class_id, :quantity, :net_price, :discount_total, :item_menu_price, :ticket_close_time, :meal_for_meal)
    end
end
