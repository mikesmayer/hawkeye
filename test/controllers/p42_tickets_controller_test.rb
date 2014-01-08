require 'test_helper'

class P42TicketsControllerTest < ActionController::TestCase
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
    assert_difference('P42Ticket.count') do
      post :create, p42_ticket: { gross_price: @p42_ticket.gross_price, meal_for_meal: @p42_ticket.meal_for_meal, net_price: @p42_ticket.net_price, pos_ticket_id: @p42_ticket.pos_ticket_id }
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
    patch :update, id: @p42_ticket, p42_ticket: { gross_price: @p42_ticket.gross_price, meal_for_meal: @p42_ticket.meal_for_meal, net_price: @p42_ticket.net_price, pos_ticket_id: @p42_ticket.pos_ticket_id }
    assert_redirected_to p42_ticket_path(assigns(:p42_ticket))
  end

  test "should destroy p42_ticket" do
    assert_difference('P42Ticket.count', -1) do
      delete :destroy, id: @p42_ticket
    end

    assert_redirected_to p42_tickets_path
  end
end
