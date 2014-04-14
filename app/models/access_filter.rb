class AccessFilter < ActiveRecord::Base
  belongs_to :user

  after_commit :invalidate_cache

  validates_uniqueness_of :user_id
  validate :parsable_cidrs

  def ip_allowed(ip)
    parsed_cidrs.any? do |x| 
      Rails.logger.info "Checking whether #{x} includes #{ip}"
      x.includes?(ip)
    end
  end

  def parsed_cidrs
    cidrs.split(/[\r\n,]+/).map{ |x| AccessCidr.new(x) }
  end

  private

  def invalidate_cache
    Rails.cache.delete(:access_filters)
  end

  def parsable_cidrs
    Rails.logger.info "Cidrs = [#{cidrs}]"
    cidrs.split(/[\r\n,]+/).compact.map do |x| 
      Rails.logger.info "x = [#{x}]"
      begin
        AccessCidr.new(x)
      rescue
        errors.add(:cidrs, I18n.t(:label_access_filters_unparsable_cidr, :cidr => x))
      end
    end
  end
end