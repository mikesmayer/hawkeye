class P42::TicketsController < ApplicationController
  before_action :set_p42_ticket, only: [:show, :edit, :update, :destroy]

  # GET /p42/tickets
  # GET /p42/tickets.json
  def index
    @p42_tickets = P42::Ticket.all
  end

  # GET /p42/tickets/1
  # GET /p42/tickets/1.json
  def show
  end

  # GET /p42/tickets/new
  def new
    @p42_ticket = P42::Ticket.new
  end

  # GET /p42/tickets/1/edit
  def edit
  end

  # POST /p42/tickets
  # POST /p42/tickets.json
  def create
    @p42_ticket = P42::Ticket.new(p42_ticket_params)

    respond_to do |format|
      if @p42_ticket.save
        format.html { redirect_to @p42_ticket, notice: 'Ticket was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_ticket }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/tickets/1
  # PATCH/PUT /p42/tickets/1.json
  def update
    respond_to do |format|
      if @p42_ticket.update(p42_ticket_params)
        format.html { redirect_to @p42_ticket, notice: 'Ticket was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/tickets/1
  # DELETE /p42/tickets/1.json
  def destroy
    @p42_ticket.destroy
    respond_to do |format|
      format.html { redirect_to p42_tickets_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_ticket
      @p42_ticket = P42::Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_ticket_params
      params.require(:p42_ticket).permit(:auto_discount, :customer_id, :gross_price, :meal_for_meal, :manual_discount, :net_price, :ticket_close_time, :ticket_open_time, :pos_ticket_id, :customer_phone, :discount_total)
    end
end
