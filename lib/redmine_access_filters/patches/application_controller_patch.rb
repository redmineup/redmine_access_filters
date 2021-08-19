module RedmineAccessFilters
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          before_action :apply_access_filters
        end
        require "#{Rails.root}/plugins/redmine_access_filters/app/models/access_filter"
      end

      module InstanceMethods
        def apply_access_filters
          Rails.logger.info "=========== Applying access filters =============="
          Rails.logger.info "Current user is #{User.current}"
          access_filters.each do |af|
            Rails.logger.info "Checking af #{af}"
            if User.current.is_or_belongs_to?(af.owner)
              Rails.logger.info "Matched with filter #{af.id} by user"
              if af.web && !api_request?
                Rails.logger.info "Denying access because web access denied"
                logout_user
                return render_error :message => 'Access denied', :status => 403 
              end
              if af.api && api_request?
                Rails.logger.info "Denying access because API access denied"
                logout_user
                return render_error :message => 'Access denied', :status => 403 
              end
              Rails.logger.info "request.remote_ip = #{request.remote_ip}"
              unless af.ip_allowed?(request.remote_ip)
                Rails.logger.info "Denying access because request ip #{request.remote_ip} does not match filter #{af.cidrs}"
                logout_user
                return render_error :message => 'Access denied', :status => 403 
              end
              return
            end


          end
          Rails.logger.info "No filters fit"
        end

        def access_filters
          Rails.cache.fetch(:access_filters) do
            AccessFilter.order(:position).where(:active => true)
          end
        end

      end
    end
  end
end

unless ApplicationController.included_modules.include?(RedmineAccessFilters::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineAccessFilters::Patches::ApplicationControllerPatch)
end
