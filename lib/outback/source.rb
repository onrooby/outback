module Outback
  class Source
    include Configurable
    include Logging
    
    attr_reader :backup_name
    
    def initialize(backup_name)
      @backup_name = backup_name
    end
    
    def create_archive(backup_name, timestamp, tmpdir)
      raise NotImplementedError
    end
    
  end
end
