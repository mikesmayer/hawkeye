require 'test_helper'

class P42::DiscountsControllerTest < ActionController::TestCase
  setup do
    @p42_discount = p42_discounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_discounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_discount" do
    assert_difference('P42::Discount.count') do
      post :create, p42_discount: { active: @p42_discount.active, name: @p42_discount.name }
    end

    assert_redirected_to p42_discount_path(assigns(:p42_discount))
  end

  test "should show p42_discount" do
    get :show, id: @p42_discount
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_discount
    assert_response :success
  end

  test "should update p42_discount" do
    patch :update, id: @p42_discount, p42_discount: { active: @p42_discount.active, name: @p42_discount.name }
    assert_redirected_to p42_discount_path(assigns(:p42_discount))
  end

  test "should destroy p42_discount" do
    assert_difference('P42::Discount.count', -1) do
      delete :destroy, id: @p42_discount
    end

    assert_redirected_to p42_discounts_path
  end
end
