module Outback
  class DirectoryTarget < Target
    attr_reader :path
    attr_setter :user, :group, :directory_permissions, :archive_permissions, :ttl, :move
    
    def initialize(backup_name, path)
      super(backup_name)
      @path = Pathname.new(path)
    end
    
    def valid?
      (user and group) or (not user and not group)
    end
    
    def to_s
      "directory:#{path}"
    end
    
    def put(archives)
      FileUtils.mkdir_p(path) unless path.directory?
      FileUtils.chmod directory_permissions || 0700, path
      size = 0
      archives.each do |archive|
        basename = Pathname.new(archive.filename).basename
        if move
          logger.debug "moving #{archive.filename} to #{path}"
          FileUtils.mv archive.filename, path
        else
          logger.debug "copying #{archive.filename} to #{path}"
          FileUtils.cp_r archive.filename, path
        end
        archived_file = path.join(basename)
        logger.debug "setting permissions for #{archived_file}"
        FileUtils.chmod archive_permissions || 0600, archived_file
        if user && group
          logger.debug "setting owner #{user}, group #{group} for #{archived_file}"
          FileUtils.chown user, group, archived_file
        end
        size += archived_file.size
      end
      logger.info "#{move ? 'Moved' : 'Copied'} #{archives.size} archives (#{size} bytes) to #{self}"
      archives.size
    end
    
    private

    def list_all_archives
      path.files(Archive::NAME_PATTERN).map { |f| build_archive(f.to_s, f.size) }
    end
    
    def unlink_archive!(archive)
      archive.filename.unlink
    end
    
  end
end
