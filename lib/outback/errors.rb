module Outback
  class Error < StandardError; end
  
  class ConfigurationError < Error; end
  class BackupError < Error; end
  class ProcessingError < Error; end
end
