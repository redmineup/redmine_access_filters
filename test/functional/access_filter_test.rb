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
    @request.session[:user_id] = 1
    @request.env['REMOTE_ADDR'] = '192.168.0.1'    
    @group = Group.create(:name => 'Test group')
    @group.users << User.find(1)
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
    AccessFilter.create(:owner_id => "User|1", :web => true, :api => false, :cidrs => 'any')
    get :index
    assert_response 403
  end

  def test_prevents_api_access_if_specified
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => true, :cidrs => 'any')
    with_settings :rest_api_enabled => '1' do
      get :index, :params => { :format => :json, :key => User.find(1).api_key}
    end
    assert_response 403
  end

  def test_allows_http_access_if_ip_matched
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => '192.168.0.1/32')
    get :index
    assert_response :success
  end

  def test_allows_http_access_if_second_ip_matched
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => "172.16.0.0/16\r\n192.168.0.1/32")
    get :index
    assert_response :success
  end

  def test_allows_http_access_if_ip_matched_for_subnet
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => '192.168.0.0/24')
    get :index
    assert_response :success
  end

  def test_does_not_allow_http_access_if_ip_mismatched_for_subnet
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => '192.168.1.0/24')
    get :index
    assert_response 403
  end

  def test_allows_api_access_if_ip_matched
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => '192.168.0.1')
    with_settings :rest_api_enabled => '1' do
      get :index, :params => {:format => :json, :key => User.find(1).api_key}
    end

    assert_response :success
  end

  def test_allows_api_access_if_ip_matched_for_subnet
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => '192.168.0.0/24')
    with_settings :rest_api_enabled => '1' do
      get :index, :params => {:format => :json, :key => User.find(1).api_key}
    end

    assert_response :success
  end

  def test_does_not_allow_api_access_if_ip_mismatched_for_subnet
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => '192.168.1.0/24')
    with_settings :rest_api_enabled => '1' do
      get :index, :params => {:format => :json, :key => User.find(1).api_key}
    end
    assert_response 403
  end

  def test_denies_access_for_group
    AccessFilter.create(:owner_id => "Group|#{@group.to_param}", :web => true, :api => false, :cidrs => 'any')
    get :index
    assert_response 403
  end

  def test_position_means_access_if_first_matched_allows
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => 'any')
    AccessFilter.create(:owner_id => "Group|#{@group.to_param}", :web => false, :api => false, :cidrs => 'any')
    get :index
    assert_response 200
  end

  def test_position_means_deny_if_first_matched_denies
    AccessFilter.create(:owner_id => "Group|#{@group.to_param}", :web => true, :api => false, :cidrs => 'any')    
    AccessFilter.create(:owner_id => "User|1", :web => false, :api => false, :cidrs => 'any')
    get :index
    assert_response 403
  end

  def test_consider_active_flag
    AccessFilter.create(:owner_id => "Group|#{@group.to_param}", :web => true, :api => false, :cidrs => 'any', :active => false)    
    get :index    
    assert_response 200    
  end

  def test_access_filter_with_empty_cidrs_field_treated_as_any
    AccessFilter.create(:owner_id => "Group|#{@group.to_param}", :web => false, :api => false)
    get :index    
    assert_response 200    
  end

end
