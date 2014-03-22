require 'test_helper'

class P42::MenuItemsControllerTest < ActionController::TestCase
  setup do
    @p42_menu_item = p42_menu_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_menu_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_menu_item" do
    assert_difference('P42::MenuItem.count') do
      post :create, p42_menu_item: { count_meal: @p42_menu_item.count_meal, count_meal_end: @p42_menu_item.count_meal_end, count_meal_modifier: @p42_menu_item.count_meal_modifier, count_meal_start: @p42_menu_item.count_meal_start, gross_price: @p42_menu_item.gross_price, menu_item_group_id: @p42_menu_item.menu_item_group_id, name: @p42_menu_item.name, recipe_id: @p42_menu_item.recipe_id, revenue_group_id: @p42_menu_item.revenue_group_id }
    end

    assert_redirected_to p42_menu_item_path(assigns(:p42_menu_item))
  end

  test "should show p42_menu_item" do
    get :show, id: @p42_menu_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_menu_item
    assert_response :success
  end

  test "should update p42_menu_item" do
    patch :update, id: @p42_menu_item, p42_menu_item: { count_meal: @p42_menu_item.count_meal, count_meal_end: @p42_menu_item.count_meal_end, count_meal_modifier: @p42_menu_item.count_meal_modifier, count_meal_start: @p42_menu_item.count_meal_start, gross_price: @p42_menu_item.gross_price, menu_item_group_id: @p42_menu_item.menu_item_group_id, name: @p42_menu_item.name, recipe_id: @p42_menu_item.recipe_id, revenue_group_id: @p42_menu_item.revenue_group_id }
    assert_redirected_to p42_menu_item_path(assigns(:p42_menu_item))
  end

  test "should destroy p42_menu_item" do
    assert_difference('P42::MenuItem.count', -1) do
      delete :destroy, id: @p42_menu_item
    end

    assert_redirected_to p42_menu_items_path
  end
end
