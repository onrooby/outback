module Outback
  class SourceArchive < Archive
    
    def initialize(filename)
      super(filename)
      @size = @filename.size
    end
    
    def open
      filename.open
    end
    
    def unlink
      filename.unlink
    end
  end
end
