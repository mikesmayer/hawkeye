require 'test_helper'

class P42::TicketItemsControllerTest < ActionController::TestCase
  setup do
    @p42_ticket_item = p42_ticket_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_ticket_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_ticket_item" do
    assert_difference('P42::TicketItem.count') do
      post :create, p42_ticket_item: { auto_discount: @p42_ticket_item.auto_discount, gross_price: @p42_ticket_item.gross_price, item_qty: @p42_ticket_item.item_qty, manual_discount: @p42_ticket_item.manual_discount, meal_for_meal: @p42_ticket_item.meal_for_meal, menu_item_id: @p42_ticket_item.menu_item_id, menu_itme_group_id: @p42_ticket_item.menu_itme_group_id, net_price: @p42_ticket_item.net_price, pos_ticket_id: @p42_ticket_item.pos_ticket_id, pos_ticket_item_id: @p42_ticket_item.pos_ticket_item_id, revenue_group_id: @p42_ticket_item.revenue_group_id, ticket_id: @p42_ticket_item.ticket_id }
    end

    assert_redirected_to p42_ticket_item_path(assigns(:p42_ticket_item))
  end

  test "should show p42_ticket_item" do
    get :show, id: @p42_ticket_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_ticket_item
    assert_response :success
  end

  test "should update p42_ticket_item" do
    patch :update, id: @p42_ticket_item, p42_ticket_item: { auto_discount: @p42_ticket_item.auto_discount, gross_price: @p42_ticket_item.gross_price, item_qty: @p42_ticket_item.item_qty, manual_discount: @p42_ticket_item.manual_discount, meal_for_meal: @p42_ticket_item.meal_for_meal, menu_item_id: @p42_ticket_item.menu_item_id, menu_itme_group_id: @p42_ticket_item.menu_itme_group_id, net_price: @p42_ticket_item.net_price, pos_ticket_id: @p42_ticket_item.pos_ticket_id, pos_ticket_item_id: @p42_ticket_item.pos_ticket_item_id, revenue_group_id: @p42_ticket_item.revenue_group_id, ticket_id: @p42_ticket_item.ticket_id }
    assert_redirected_to p42_ticket_item_path(assigns(:p42_ticket_item))
  end

  test "should destroy p42_ticket_item" do
    assert_difference('P42::TicketItem.count', -1) do
      delete :destroy, id: @p42_ticket_item
    end

    assert_redirected_to p42_ticket_items_path
  end
end
