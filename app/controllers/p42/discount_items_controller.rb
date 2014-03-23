class P42::DiscountItemsController < ApplicationController
  before_action :set_p42_discount_item, only: [:show, :edit, :update, :destroy]

  # GET /p42/discount_items
  # GET /p42/discount_items.json
  def index
    @p42_discount_items = P42::DiscountItem.all
  end

  # GET /p42/discount_items/1
  # GET /p42/discount_items/1.json
  def show
  end

  # GET /p42/discount_items/new
  def new
    @p42_discount_item = P42::DiscountItem.new
  end

  # GET /p42/discount_items/1/edit
  def edit
  end

  # POST /p42/discount_items
  # POST /p42/discount_items.json
  def create
    @p42_discount_item = P42::DiscountItem.new(p42_discount_item_params)

    respond_to do |format|
      if @p42_discount_item.save
        format.html { redirect_to @p42_discount_item, notice: 'Discount item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_discount_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_discount_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/discount_items/1
  # PATCH/PUT /p42/discount_items/1.json
  def update
    respond_to do |format|
      if @p42_discount_item.update(p42_discount_item_params)
        format.html { redirect_to @p42_discount_item, notice: 'Discount item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_discount_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/discount_items/1
  # DELETE /p42/discount_items/1.json
  def destroy
    @p42_discount_item.destroy
    respond_to do |format|
      format.html { redirect_to p42_discount_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_discount_item
      @p42_discount_item = P42::DiscountItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_discount_item_params
      params.require(:p42_discount_item).permit(:auto_apply, :discount_amount, :discount_item_id, :menu_item_id, :pos_ticket_id, :pos_ticket_item_id, :reason_text, :ticket_id, :ticket_item_id, :ticket_item_price, :when)
    end
end
