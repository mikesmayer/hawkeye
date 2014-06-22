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
      post :create, p42_ticket_item: { category_id: @p42_ticket_item.category_id, choice_additions_total: @p42_ticket_item.choice_additions_total, customer_original_id: @p42_ticket_item.customer_original_id, discount_total: @p42_ticket_item.discount_total, item_menu_price: @p42_ticket_item.item_menu_price, menu_item_id: @p42_ticket_item.menu_item_id, net_price: @p42_ticket_item.net_price, quantity: @p42_ticket_item.quantity, revenue_class_id: @p42_ticket_item.revenue_class_id, ticket_close_time: @p42_ticket_item.ticket_close_time, ticket_id: @p42_ticket_item.ticket_id, ticket_item_id: @p42_ticket_item.ticket_item_id }
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
    patch :update, id: @p42_ticket_item, p42_ticket_item: { category_id: @p42_ticket_item.category_id, choice_additions_total: @p42_ticket_item.choice_additions_total, customer_original_id: @p42_ticket_item.customer_original_id, discount_total: @p42_ticket_item.discount_total, item_menu_price: @p42_ticket_item.item_menu_price, menu_item_id: @p42_ticket_item.menu_item_id, net_price: @p42_ticket_item.net_price, quantity: @p42_ticket_item.quantity, revenue_class_id: @p42_ticket_item.revenue_class_id, ticket_close_time: @p42_ticket_item.ticket_close_time, ticket_id: @p42_ticket_item.ticket_id, ticket_item_id: @p42_ticket_item.ticket_item_id }
    assert_redirected_to p42_ticket_item_path(assigns(:p42_ticket_item))
  end

  test "should destroy p42_ticket_item" do
    assert_difference('P42::TicketItem.count', -1) do
      delete :destroy, id: @p42_ticket_item
    end

    assert_redirected_to p42_ticket_items_path
  end
end
