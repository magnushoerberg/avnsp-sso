module Hashable
  def to_h
    self.class.superclass.new(*self.values).each_pair.map do |k, v|
      value = if v.respond_to?(:to_h)
                v.to_h
              else
                v
              end
      { k => value }
    end.inject(&:merge)
  end
end

