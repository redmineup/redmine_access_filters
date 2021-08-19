Redmine::Plugin.register :redmine_access_filters do
  name 'Redmine Access Filters plugin'
  author 'Redmine CRM'
  description 'Allows setting access filters for API and regular browser access per user'
  version '1.0.1'
  url 'https://github.com/ngiger/redmine_access_filters'
  author_url 'mailto:niklaus.giger@member.fsf.org'
  menu :admin_menu, :access_filters,
                          {:controller => 'access_filters', :action => 'index'},
                          :caption => :label_access_filters_plural

end

require 'redmine_access_filters'
