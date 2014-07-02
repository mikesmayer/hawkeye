class P42::MenuItemsController < ApplicationController
  before_action :set_p42_menu_item, only: [:show, :edit, :update, :destroy]

  # GET /p42/menu_items
  # GET /p42/menu_items.json
  def index
    @p42_item_categories = P42::MenuItemGroup.order("name ASC").all

    @p42_menu_items = P42::MenuItem.order("id ASC").all
    @food_not_counted = P42::MenuItem.includes('meal_count_rules').where("p42_meal_count_rules.id IS NULL AND (menu_item_group_id = 40 OR
        menu_item_group_id = 41 OR menu_item_group_id = 42 OR menu_item_group_id = 43 OR
        menu_item_group_id = 52 OR menu_item_group_id = 53 OR menu_item_group_id = 54 OR
        menu_item_group_id = 50 OR menu_item_group_id = 47)")
    @apparel_items_modifier_not_set = P42::MenuItem.where("revenue_group_id = 18")
    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @p42_menu_items }
    end
  end
  # GET /p42/menu_items/1
  # GET /p42/menu_items/1.json
  def show
    #this is here for the modal used on the menu item show page that adds new rules to a given menu item
    @p42_meal_count_rule = P42::MealCountRule.new
    @num_rules = @p42_menu_item.meal_count_rules.count

  end

  # GET /p42/menu_items/new
  def new
    @p42_menu_item = P42::MenuItem.new
  end

  # GET /p42/menu_items/1/edit
  def edit
  end

  # POST /p42/menu_items
  # POST /p42/menu_items.json
  def create
    @p42_menu_item = P42::MenuItem.new(p42_menu_item_params)

    respond_to do |format|
      if @p42_menu_item.save
        format.html { redirect_to @p42_menu_item, notice: 'Menu item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_menu_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_menu_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/menu_items/1
  # PATCH/PUT /p42/menu_items/1.json
  def update
    respond_to do |format|
      if @p42_menu_item.update(p42_menu_item_params)
        format.html { redirect_to @p42_menu_item, notice: 'Menu item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_menu_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/menu_items/1
  # DELETE /p42/menu_items/1.json
  def destroy
    @p42_menu_item.destroy
    respond_to do |format|
      format.html { redirect_to p42_menu_items_url }
      format.json { head :no_content }
    end
  end

  def sync_menu_items
    flash[:notice] = P42::MenuItem.sync_menu_items
    redirect_to p42_menu_items_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_menu_item
      @p42_menu_item = P42::MenuItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_menu_item_params
      params.require(:p42_menu_item).permit(:gross_price, :menu_item_group_id, :name, :recipe_id, :revenue_group_id, :count_meal, :count_meal_modifier)
    end
end
