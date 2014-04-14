module RedmineAccessFilters
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        stylesheet_link_tag(:redmine_access_filters, :plugin => 'redmine_access_filters')
      end
    end
  end
end