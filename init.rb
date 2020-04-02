Redmine::Plugin.register :redmine_access_filters do
  name 'Redmine Access Filters plugin'
  author 'Redmine CRM'
  description 'Allows setting access filters for API and regular browser access per user'
  version '0.0.2'
  url 'http://redminecrm.com'
  author_url 'mailto:support@redminecrm.com'
  menu :admin_menu, :access_filters,
                          {:controller => 'access_filters', :action => 'index'},
                          :caption => :label_access_filters_plural

end

require 'redmine_access_filters'
