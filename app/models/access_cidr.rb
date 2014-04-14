class AccessCidr
  def initialize(record)
    @any = true if record == 'any'
    @cidr = NetAddr::CIDR.create(record) unless @any
  end

  def includes?(ip)
    return true if @any
    @cidr.matches?(ip)
  end

  def to_s
    return "any" if @any
    return @cidr.to_s if @cidr
  end
end