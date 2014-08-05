class P42::DiscountsController < ApplicationController
  authorize_resource
  
  before_action :set_p42_discount, only: [:show, :edit, :update, :destroy]

  # GET /p42/discounts
  # GET /p42/discounts.json
  def index
    @p42_discounts = P42::Discount.all
  end

  # GET /p42/discounts/1
  # GET /p42/discounts/1.json
  def show
  end

  # GET /p42/discounts/new
  def new
    @p42_discount = P42::Discount.new
  end

  # GET /p42/discounts/1/edit
  def edit
  end

  # POST /p42/discounts
  # POST /p42/discounts.json
  def create
    @p42_discount = P42::Discount.new(p42_discount_params)

    respond_to do |format|
      if @p42_discount.save
        format.html { redirect_to @p42_discount, notice: 'Discount was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_discount }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/discounts/1
  # PATCH/PUT /p42/discounts/1.json
  def update
    respond_to do |format|
      if @p42_discount.update(p42_discount_params)
        format.html { redirect_to @p42_discount, notice: 'Discount was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/discounts/1
  # DELETE /p42/discounts/1.json
  def destroy
    @p42_discount.destroy
    respond_to do |format|
      format.html { redirect_to p42_discounts_url }
      format.json { head :no_content }
    end
  end

  def sync_discounts
    flash[:notice] = P42::Discount.sync_discounts
    redirect_to p42_discounts_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_discount
      @p42_discount = P42::Discount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_discount_params
      params.require(:p42_discount).permit(:active, :name)
    end
end
