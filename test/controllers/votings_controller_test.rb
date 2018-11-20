require 'test_helper'

class VotingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get votings_index_url
    assert_response :success
  end

end
