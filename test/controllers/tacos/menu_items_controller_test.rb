require 'test_helper'

class Tacos::MenuItemsControllerTest < ActionController::TestCase
  setup do
    @tacos_menu_item = tacos_menu_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tacos_menu_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tacos_menu_item" do
    assert_difference('Tacos::MenuItem.count') do
      post :create, tacos_menu_item: { menu_item_group_id: @tacos_menu_item.menu_item_group_id, name: @tacos_menu_item.name, recipe_id: @tacos_menu_item.recipe_id }
    end

    assert_redirected_to tacos_menu_item_path(assigns(:tacos_menu_item))
  end

  test "should show tacos_menu_item" do
    get :show, id: @tacos_menu_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tacos_menu_item
    assert_response :success
  end

  test "should update tacos_menu_item" do
    patch :update, id: @tacos_menu_item, tacos_menu_item: { menu_item_group_id: @tacos_menu_item.menu_item_group_id, name: @tacos_menu_item.name, recipe_id: @tacos_menu_item.recipe_id }
    assert_redirected_to tacos_menu_item_path(assigns(:tacos_menu_item))
  end

  test "should destroy tacos_menu_item" do
    assert_difference('Tacos::MenuItem.count', -1) do
      delete :destroy, id: @tacos_menu_item
    end

    assert_redirected_to tacos_menu_items_path
  end
end
