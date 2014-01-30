require 'test_helper'

class P42::TicketsControllerTest < ActionController::TestCase
  setup do
    @p42_ticket = p42_tickets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_tickets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_ticket" do
    assert_difference('P42::Ticket.count') do
      post :create, p42_ticket: { auto_discount: @p42_ticket.auto_discount, customer_id: @p42_ticket.customer_id, customer_phone: @p42_ticket.customer_phone, discount_total: @p42_ticket.discount_total, gross_price: @p42_ticket.gross_price, manual_discount: @p42_ticket.manual_discount, meal_for_meal: @p42_ticket.meal_for_meal, net_price: @p42_ticket.net_price, pos_ticket_id: @p42_ticket.pos_ticket_id, ticket_close_time: @p42_ticket.ticket_close_time, ticket_open_time: @p42_ticket.ticket_open_time }
    end

    assert_redirected_to p42_ticket_path(assigns(:p42_ticket))
  end

  test "should show p42_ticket" do
    get :show, id: @p42_ticket
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_ticket
    assert_response :success
  end

  test "should update p42_ticket" do
    patch :update, id: @p42_ticket, p42_ticket: { auto_discount: @p42_ticket.auto_discount, customer_id: @p42_ticket.customer_id, customer_phone: @p42_ticket.customer_phone, discount_total: @p42_ticket.discount_total, gross_price: @p42_ticket.gross_price, manual_discount: @p42_ticket.manual_discount, meal_for_meal: @p42_ticket.meal_for_meal, net_price: @p42_ticket.net_price, pos_ticket_id: @p42_ticket.pos_ticket_id, ticket_close_time: @p42_ticket.ticket_close_time, ticket_open_time: @p42_ticket.ticket_open_time }
    assert_redirected_to p42_ticket_path(assigns(:p42_ticket))
  end

  test "should destroy p42_ticket" do
    assert_difference('P42::Ticket.count', -1) do
      delete :destroy, id: @p42_ticket
    end

    assert_redirected_to p42_tickets_path
  end
end
