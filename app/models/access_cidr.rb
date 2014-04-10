class AccessCidr
  def initialize(record)
    @any = true if record == 'any'
    @cidr = NetAddr::CIDR.create(record) unless @any
  end

  def includes?(ip)
    return true if @any
    @cidr.matches?(ip)
  end
end