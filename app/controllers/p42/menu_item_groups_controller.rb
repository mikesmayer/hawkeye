class P42::MenuItemGroupsController < ApplicationController
  before_action :set_p42_menu_item_group, only: [:show, :edit, :update, :destroy]

  # GET /p42/menu_item_groups
  # GET /p42/menu_item_groups.json
  def index
    @p42_menu_item_groups = P42::MenuItemGroup.order("id ASC").all
  end

  # GET /p42/menu_item_groups/1
  # GET /p42/menu_item_groups/1.json
  def show
  end

  # GET /p42/menu_item_groups/new
  def new
    @p42_menu_item_group = P42::MenuItemGroup.new
  end

  # GET /p42/menu_item_groups/1/edit
  def edit
  end

  # POST /p42/menu_item_groups
  # POST /p42/menu_item_groups.json
  def create
    @p42_menu_item_group = P42::MenuItemGroup.new(p42_menu_item_group_params)

    respond_to do |format|
      if @p42_menu_item_group.save
        format.html { redirect_to @p42_menu_item_group, notice: 'Menu item group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_menu_item_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_menu_item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/menu_item_groups/1
  # PATCH/PUT /p42/menu_item_groups/1.json
  def update
    respond_to do |format|
      if @p42_menu_item_group.update(p42_menu_item_group_params)
        format.html { redirect_to @p42_menu_item_group, notice: 'Menu item group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_menu_item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/menu_item_groups/1
  # DELETE /p42/menu_item_groups/1.json
  def destroy
    @p42_menu_item_group.destroy
    respond_to do |format|
      format.html { redirect_to p42_menu_item_groups_url }
      format.json { head :no_content }
    end
  end

  def sync_menu_item_groups
    flash[:notice] = P42::MenuItemGroup.sync_menu_item_groups
    redirect_to p42_menu_item_groups_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_menu_item_group
      @p42_menu_item_group = P42::MenuItemGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_menu_item_group_params
      params.require(:p42_menu_item_group).permit(:name, :default_meal_modifier)
    end
end
