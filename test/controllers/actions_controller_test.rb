require "test_helper"

class ActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @action = actions(:one)
  end

  test "should get index" do
    get actions_url
    assert_response :success
  end

  test "should get new" do
    get new_action_url
    assert_response :success
  end

  test "should create action" do
    assert_difference("Action.count") do
      post actions_url, params: { action: { created_at: @action.created_at, date: @action.date, description: @action.description, promise_id: @action.promise_id, updated_at: @action.updated_at } }
    end

    assert_redirected_to action_url(Action.last)
  end

  test "should show action" do
    get action_url(@action)
    assert_response :success
  end

  test "should get edit" do
    get edit_action_url(@action)
    assert_response :success
  end

  test "should update action" do
    patch action_url(@action), params: { action: { created_at: @action.created_at, date: @action.date, description: @action.description, promise_id: @action.promise_id, updated_at: @action.updated_at } }
    assert_redirected_to action_url(@action)
  end

  test "should destroy action" do
    assert_difference("Action.count", -1) do
      delete action_url(@action)
    end

    assert_redirected_to actions_url
  end
end
