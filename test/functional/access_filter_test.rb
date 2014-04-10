require File.expand_path('../../test_helper', __FILE__)

class ApplicationControllerTest < ActionController::TestCase
  fixtures :projects, :issues, :issue_statuses,
           :enumerations, :users, :issue_categories,
           :trackers,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows,
           :journals, :journal_details

  def setup
    Rails.cache.clear
    AccessFilter.destroy_all

    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1
    @request.env['REMOTE_ADDR'] = '192.168.0.1'    
  end

  def test_works_if_no_rules_exist
    get :index
    assert_response :success
  end

  def test_works_for_api_if_no_rules_exist
    get :index, :format => :json
    assert_response :success
  end

  def test_prevents_http_access_if_specified
    AccessFilter.create(:user_id => 1, :web => false, :api => true, :cidrs => 'any')
    get :index
    assert_response 403
  end

  def test_prevents_api_access_if_specified
    AccessFilter.create(:user_id => 1, :web => true, :api => false, :cidrs => 'any')
    with_settings :rest_api_enabled => '1' do
      get :index, :format => :json, :key => User.find(1).api_key
    end
    assert_response 403
  end

  def test_allows_http_access_if_ip_matched
    AccessFilter.create(:user_id => 1, :web => true, :api => true, :cidrs => '192.168.0.1')
    get :index
    assert_response :success
  end

  def test_allows_http_access_if_ip_matched_for_subnet
    AccessFilter.create(:user_id => 1, :web => true, :api => true, :cidrs => '192.168.0.0/24')
    get :index
    assert_response :success
  end

  def test_does_not_allow_http_access_if_ip_mismatched_for_subnet
    AccessFilter.create(:user_id => 1, :web => false, :api => true, :cidrs => '192.168.1.0/24')
    get :index
    assert_response 403
  end

  def test_allows_api_access_if_ip_matched
    AccessFilter.create(:user_id => 1, :web => false, :api => true, :cidrs => '192.168.0.1')
    with_settings :rest_api_enabled => '1' do
      get :index, :format => :json, :key => User.find(1).api_key
    end

    assert_response :success
  end

  def test_allows_api_access_if_ip_matched_for_subnet
    AccessFilter.create(:user_id => 1, :web => false, :api => true, :cidrs => '192.168.0.0/24')
    with_settings :rest_api_enabled => '1' do
      get :index, :format => :json, :key => User.find(1).api_key
    end

    assert_response :success
  end

  def test_does_not_allow_api_access_if_ip_mismatched_for_subnet
    AccessFilter.create(:user_id => 1, :web => false, :api => true, :cidrs => '192.168.1.0/24')
    with_settings :rest_api_enabled => '1' do
      get :index, :format => :json, :key => User.find(1).api_key
    end

    assert_response 403
  end

end