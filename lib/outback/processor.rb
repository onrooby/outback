module Outback
  class Processor
    include Configurable
    include Logging
    
    attr_reader :backup_name
    
    def initialize(backup_name)
      @backup_name = backup_name
    end
        
    def process!(archives)
      archives.map { |archive| process_archive!(archive) }.flatten.compact
    end
    
  end
end
