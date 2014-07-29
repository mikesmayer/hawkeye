class Tacos::MenuItemsController < ApplicationController
  before_action :set_tacos_menu_item, only: [:show, :edit, :update, :destroy]

  # GET /tacos/menu_items
  # GET /tacos/menu_items.json
  def index
    @tacos_item_categories = Tacos::MenuItemGroup.order("name ASC").all

    @tacos_menu_items = Tacos::MenuItem.order("id ASC").all
    @food_not_counted = Tacos::MenuItem.includes('meal_count_rules').where("tacos_meal_count_rules.id IS NULL AND (menu_item_group_id = 40 OR
        menu_item_group_id = 41 OR menu_item_group_id = 42 OR menu_item_group_id = 43 OR
        menu_item_group_id = 52 OR menu_item_group_id = 53 OR menu_item_group_id = 54 OR
        menu_item_group_id = 50 OR menu_item_group_id = 47)")
    @apparel_items_modifier_not_set = Tacos::MenuItem.includes('meal_count_rules').where("tacos_meal_count_rules.id IS NULL")
    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tacos_menu_items }
    end
  end

  # GET /tacos/menu_items/1
  # GET /tacos/menu_items/1.json
  def show
    #this is here for the modal used on the menu item show page that adds new rules to a given menu item
    @tacos_meal_count_rule = Tacos::MealCountRule.new
    @num_rules = @tacos_menu_item.meal_count_rules.count
  end

  # GET /tacos/menu_items/new
  def new
    @tacos_menu_item = Tacos::MenuItem.new
  end

  # GET /tacos/menu_items/1/edit
  def edit
  end

  # POST /tacos/menu_items
  # POST /tacos/menu_items.json
  def create
    @tacos_menu_item = Tacos::MenuItem.new(tacos_menu_item_params)

    respond_to do |format|
      if @tacos_menu_item.save
        format.html { redirect_to @tacos_menu_item, notice: 'Menu item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tacos_menu_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @tacos_menu_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tacos/menu_items/1
  # PATCH/PUT /tacos/menu_items/1.json
  def update
    respond_to do |format|
      if @tacos_menu_item.update(tacos_menu_item_params)
        format.html { redirect_to @tacos_menu_item, notice: 'Menu item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tacos_menu_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tacos/menu_items/1
  # DELETE /tacos/menu_items/1.json
  def destroy
    @tacos_menu_item.destroy
    respond_to do |format|
      format.html { redirect_to tacos_menu_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tacos_menu_item
      @tacos_menu_item = Tacos::MenuItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tacos_menu_item_params
      params.require(:tacos_menu_item).permit(:menu_item_group_id, :name, :recipe_id)
    end
end
