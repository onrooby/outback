module Outback
  class Archive
    NAME_PATTERN = /\A([A-Za-z0-9.\-]+)_(\d{14})_(\w+)/
    
    attr_reader :filename, :backup_name, :timestamp, :source_name, :size
    
    def initialize(filename)
      @filename = Pathname.new(filename)
      unless match_data = @filename.basename.to_s.match(NAME_PATTERN)
        raise ArgumentError, 'invalid name'
      end
      @backup_name, @timestamp, @source_name = match_data.captures[0..2]
    end
    
    def to_s
      "#{filename}"
    end
  end
end
