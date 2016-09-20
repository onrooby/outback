module Outback
  class TargetArchive < Archive
    attr_reader :target
    
    def initialize(filename, size, target)
      super(filename)
      @size = size
      @target = target
    end    
    
    def match?(name)
      name == backup_name
    end
    
    def ttl
      target && target.ttl
    end

    def outdated?
      if timestamp && ttl
        Time.now - Time.strptime(timestamp, Outback::TIME_FORMAT) > ttl
      end
    end
    
    def to_s
      "#{target}: #{filename}"
    end
     
  end
end
