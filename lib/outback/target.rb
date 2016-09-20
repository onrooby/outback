module Outback
  class Target
    include Configurable
    include Logging
    
    attr_reader :backup_name
    
    def initialize(backup_name)
      @backup_name = backup_name
    end
    
    def purge!
      purged_archives = connect { purge_archives }
      logger.info "Purged #{purged_archives.size} archives (#{purged_archives.sum(&:size)} bytes) from #{self}"
    end
    
    private
    
    def connection
      @connection
    end
    
    def connect
      yield
    end
    
    def build_archive(filename, size)
      TargetArchive.new(filename, size, self)
    end
    
    def list_all_archives
      raise NotImplemented
    end
    
    def archives
      list_all_archives.select(&it.match?(backup_name))
    end
    
    def purge_archives
      archives.select do |archive|
        if archive.outdated?
          begin
            logger.debug "purging archive: #{archive}"
            unlink_archive!(archive)
            true
          rescue => e
            logger.error "could not unlink archive #{archive}: #{e} #{e.message}"
            false
          end
        end
      end
    end
    
    def unlink_archive!(archive)
      raise NotImplemented
    end
  
  end
end
