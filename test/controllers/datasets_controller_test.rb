require "test_helper"

class DatasetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get datasets_index_url
    assert_response :success
  end
end
