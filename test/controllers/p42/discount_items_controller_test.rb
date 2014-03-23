require 'test_helper'

class P42::DiscountItemsControllerTest < ActionController::TestCase
  setup do
    @p42_discount_item = p42_discount_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_discount_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_discount_item" do
    assert_difference('P42::DiscountItem.count') do
      post :create, p42_discount_item: { auto_apply: @p42_discount_item.auto_apply, discount_amount: @p42_discount_item.discount_amount, discount_item_id: @p42_discount_item.discount_item_id, menu_item_id: @p42_discount_item.menu_item_id, pos_ticket_id: @p42_discount_item.pos_ticket_id, pos_ticket_item_id: @p42_discount_item.pos_ticket_item_id, reason_text: @p42_discount_item.reason_text, ticket_id: @p42_discount_item.ticket_id, ticket_item_id: @p42_discount_item.ticket_item_id, ticket_item_price: @p42_discount_item.ticket_item_price, when: @p42_discount_item.when }
    end

    assert_redirected_to p42_discount_item_path(assigns(:p42_discount_item))
  end

  test "should show p42_discount_item" do
    get :show, id: @p42_discount_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_discount_item
    assert_response :success
  end

  test "should update p42_discount_item" do
    patch :update, id: @p42_discount_item, p42_discount_item: { auto_apply: @p42_discount_item.auto_apply, discount_amount: @p42_discount_item.discount_amount, discount_item_id: @p42_discount_item.discount_item_id, menu_item_id: @p42_discount_item.menu_item_id, pos_ticket_id: @p42_discount_item.pos_ticket_id, pos_ticket_item_id: @p42_discount_item.pos_ticket_item_id, reason_text: @p42_discount_item.reason_text, ticket_id: @p42_discount_item.ticket_id, ticket_item_id: @p42_discount_item.ticket_item_id, ticket_item_price: @p42_discount_item.ticket_item_price, when: @p42_discount_item.when }
    assert_redirected_to p42_discount_item_path(assigns(:p42_discount_item))
  end

  test "should destroy p42_discount_item" do
    assert_difference('P42::DiscountItem.count', -1) do
      delete :destroy, id: @p42_discount_item
    end

    assert_redirected_to p42_discount_items_path
  end
end
