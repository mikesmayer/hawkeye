class Tacos::MenuItemGroupsController < ApplicationController
  authorize_resource
  
  before_action :set_tacos_menu_item_group, only: [:show, :edit, :update, :destroy]

  # GET /tacos/menu_item_groups
  # GET /tacos/menu_item_groups.json
  def index
    @tacos_menu_item_groups = Tacos::MenuItemGroup.all
  end

  # GET /tacos/menu_item_groups/1
  # GET /tacos/menu_item_groups/1.json
  def show
  end

  # GET /tacos/menu_item_groups/new
  def new
    @tacos_menu_item_group = Tacos::MenuItemGroup.new
  end

  # GET /tacos/menu_item_groups/1/edit
  def edit
  end

  # POST /tacos/menu_item_groups
  # POST /tacos/menu_item_groups.json
  def create
    @tacos_menu_item_group = Tacos::MenuItemGroup.new(tacos_menu_item_group_params)

    respond_to do |format|
      if @tacos_menu_item_group.save
        format.html { redirect_to @tacos_menu_item_group, notice: 'Menu item group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tacos_menu_item_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @tacos_menu_item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tacos/menu_item_groups/1
  # PATCH/PUT /tacos/menu_item_groups/1.json
  def update
    respond_to do |format|
      if @tacos_menu_item_group.update(tacos_menu_item_group_params)
        format.html { redirect_to @tacos_menu_item_group, notice: 'Menu item group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tacos_menu_item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tacos/menu_item_groups/1
  # DELETE /tacos/menu_item_groups/1.json
  def destroy
    @tacos_menu_item_group.destroy
    respond_to do |format|
      format.html { redirect_to tacos_menu_item_groups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tacos_menu_item_group
      @tacos_menu_item_group = Tacos::MenuItemGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tacos_menu_item_group_params
      params.require(:tacos_menu_item_group).permit(:name, :default_meal_modifier)
    end
end
