module Outback
  module PathnameExt
    def files(regexp = nil)
      returning Dir[join('**')].map { |f| Pathname.new(f) }.select(&:file?) do |entries|
        entries.delete_if { |f| not f.basename.to_s.match(regexp) } if regexp
      end
    end
    
    def directories(regexp = nil)
      returning Dir[join('**')].map { |f| Pathname.new(f) }.select(&:directory?) do |entries|
        entries.delete_if { |f| not f.basename.to_s.match(regexp) } if regexp
      end
    end    
  end
end

Pathname.send :include, Outback::PathnameExt