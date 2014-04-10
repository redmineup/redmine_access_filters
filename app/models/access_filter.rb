class AccessFilter < ActiveRecord::Base
  belongs_to :user

  after_commit :invalidate_cache

  validates_uniqueness_of :user_id
  validate :parsable_cidrs

  def ip_allowed(ip)
    parsed_cidrs.any?{ |x| x.includes?(ip) }
  end

  def parsed_cidrs
    cidrs.split("\n,").map{ |x| AccessCidr.new(x) }
  end

  private

  def invalidate_cache
    Rails.cache.delete(:access_filters)
  end

  def parsable_cidrs
    cidrs.split("\n,").map do |x| 
      begin
        AccessCidr.new(x)
      rescue
        errors.add(:cidrs, I18n.t(:label_access_filters_unparsable_cidr, :cidr => x))
      end
    end
  end
end