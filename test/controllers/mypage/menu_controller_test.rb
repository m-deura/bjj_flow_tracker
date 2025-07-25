require "test_helper"

class Mypage::MenuControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get mypage_menu_show_url
    assert_response :success
  end
end
