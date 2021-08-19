class AccessFilter < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  after_commit :invalidate_cache

  validate :parsable_cidrs

  acts_as_tree

  # That is to clear cache on startup
  Rails.cache.delete(:access_filters)

  def ip_allowed?(ip)
    parsed_cidrs.any? do |x| 
      Rails.logger.info "Checking whether #{x} includes #{ip}"
      x.includes?(ip)
    end
  end

  def parsed_cidrs
    cidrs.present? ? cidrs.split(/[\r\n,]+/).map{ |x| AccessCidr.new(x) } : [ AccessCidr.new('any') ]
  end

  def owner_id=(id_and_class)
    type, id = id_and_class.split('|')
    self.owner_type = type
    super id
  end

  def to_s
    "#{owner.name}:denyweb-#{web},denyapi-#{api},ip-#{parsed_cidrs}"
  end

  private

  def invalidate_cache
    Rails.cache.delete(:access_filters)
  end

  def parsable_cidrs
    Rails.logger.info "Cidrs = [#{cidrs}]"
    if cidrs?
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
end
