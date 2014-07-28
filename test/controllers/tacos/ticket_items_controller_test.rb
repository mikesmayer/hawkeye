require 'test_helper'

class Tacos::TicketItemsControllerTest < ActionController::TestCase
  setup do
    @tacos_ticket_item = tacos_ticket_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tacos_ticket_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tacos_ticket_item" do
    assert_difference('Tacos::TicketItem.count') do
      post :create, tacos_ticket_item: { discount_total: @tacos_ticket_item.discount_total, item_menu_price: @tacos_ticket_item.item_menu_price, meal_for_meal: @tacos_ticket_item.meal_for_meal, menu_item_id: @tacos_ticket_item.menu_item_id, net_price: @tacos_ticket_item.net_price, pos_category_id: @tacos_ticket_item.pos_category_id, pos_revenue_class_id: @tacos_ticket_item.pos_revenue_class_id, pos_ticket_id: @tacos_ticket_item.pos_ticket_id, pos_ticket_item_id: @tacos_ticket_item.pos_ticket_item_id, quantity: @tacos_ticket_item.quantity, ticket_close_time: @tacos_ticket_item.ticket_close_time }
    end

    assert_redirected_to tacos_ticket_item_path(assigns(:tacos_ticket_item))
  end

  test "should show tacos_ticket_item" do
    get :show, id: @tacos_ticket_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tacos_ticket_item
    assert_response :success
  end

  test "should update tacos_ticket_item" do
    patch :update, id: @tacos_ticket_item, tacos_ticket_item: { discount_total: @tacos_ticket_item.discount_total, item_menu_price: @tacos_ticket_item.item_menu_price, meal_for_meal: @tacos_ticket_item.meal_for_meal, menu_item_id: @tacos_ticket_item.menu_item_id, net_price: @tacos_ticket_item.net_price, pos_category_id: @tacos_ticket_item.pos_category_id, pos_revenue_class_id: @tacos_ticket_item.pos_revenue_class_id, pos_ticket_id: @tacos_ticket_item.pos_ticket_id, pos_ticket_item_id: @tacos_ticket_item.pos_ticket_item_id, quantity: @tacos_ticket_item.quantity, ticket_close_time: @tacos_ticket_item.ticket_close_time }
    assert_redirected_to tacos_ticket_item_path(assigns(:tacos_ticket_item))
  end

  test "should destroy tacos_ticket_item" do
    assert_difference('Tacos::TicketItem.count', -1) do
      delete :destroy, id: @tacos_ticket_item
    end

    assert_redirected_to tacos_ticket_items_path
  end
end
