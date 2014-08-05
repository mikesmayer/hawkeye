class P42::RevenueGroupsController < ApplicationController
  authorize_resource
  
  before_action :set_p42_revenue_group, only: [:show, :edit, :update, :destroy]

  # GET /p42/revenue_groups
  # GET /p42/revenue_groups.json
  def index
    @p42_revenue_groups = P42::RevenueGroup.all
  end

  # GET /p42/revenue_groups/1
  # GET /p42/revenue_groups/1.json
  def show
  end

  # GET /p42/revenue_groups/new
  def new
    @p42_revenue_group = P42::RevenueGroup.new
  end

  # GET /p42/revenue_groups/1/edit
  def edit
  end

  # POST /p42/revenue_groups
  # POST /p42/revenue_groups.json
  def create
    @p42_revenue_group = P42::RevenueGroup.new(p42_revenue_group_params)

    respond_to do |format|
      if @p42_revenue_group.save
        format.html { redirect_to @p42_revenue_group, notice: 'Revenue group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_revenue_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_revenue_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/revenue_groups/1
  # PATCH/PUT /p42/revenue_groups/1.json
  def update
    respond_to do |format|
      if @p42_revenue_group.update(p42_revenue_group_params)
        format.html { redirect_to @p42_revenue_group, notice: 'Revenue group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_revenue_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/revenue_groups/1
  # DELETE /p42/revenue_groups/1.json
  def destroy
    @p42_revenue_group.destroy
    respond_to do |format|
      format.html { redirect_to p42_revenue_groups_url }
      format.json { head :no_content }
    end
  end

  def sync_revenue_groups
    flash[:notice] = P42::RevenueGroup.sync_revenue_groups
    redirect_to p42_revenue_groups_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_revenue_group
      @p42_revenue_group = P42::RevenueGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_revenue_group_params
      params.require(:p42_revenue_group).permit(:name)
    end
end
