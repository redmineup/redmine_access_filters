module RedmineAccessFilters
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          before_filter :apply_access_filters
        end
        require "#{Rails.root}/plugins/redmine_access_filters/app/models/access_filter"
      end

      module InstanceMethods
        def apply_access_filters
          Rails.logger.info "=========== Applying access filters =============="
          Rails.logger.info "Current user is #{User.current}"
          user = User.current.id
          if access_filters.has_key?(User.current.id)
            Rails.logger.info "Rule for user #{User.current} was found"
            access_filter = access_filters[User.current.id]
            Rails.logger.info ": #{access_filter.inspect}"
            unless access_filter.web || api_request?
              Rails.logger.info "Denying access because web access denied for user"
              return render_error :message => 'Access denied', :status => 403 
            end
            unless access_filter.api || !api_request?
              Rails.logger.info "Denying access because API access denied for user"
              return render_error :message => 'Access denied', :status => 403 
            end
            Rails.logger.info "request.remote_ip = #{request.remote_ip}"
            unless access_filter.ip_allowed(request.remote_ip)
              Rails.logger.info "Denying access because request ip #{request.remote_ip} does not match filter #{access_filter.cidrs}"
              return render_error :message => 'Access denied', :status => 403 
            end
          else
            Rails.logger.info "------- No filters for user"
          end
        end

        def access_filters
          Rails.cache.fetch(:access_filters) do
            Hash[AccessFilter.all.map{ |x| [x.user.id, x]}]
          end
        end

      end
    end
  end
end

unless ApplicationController.included_modules.include?(RedmineAccessFilters::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineAccessFilters::Patches::ApplicationControllerPatch)
end