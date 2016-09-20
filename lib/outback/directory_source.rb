module Outback
  class DirectorySource < Source
    attr_reader :path
    
    def initialize(backup_name, path)
      super(backup_name)
      @path = path
    end
    
    def source_name
      path.gsub(/[^A-Za-z0-9\-_.]/, '_').gsub(/(\A_|_\z)/, '')
    end
    
    def excludes
      @excludes ||= []
    end
    
    def exclude(*paths)
      excludes.concat(paths.map(&:to_s)).uniq!
    end
    
    def create_archives(timestamp, tmpdir)
      source_dir = Pathname.new(path).realpath
      archive_name = Pathname.new(tmpdir).join("#{backup_name}_#{timestamp}_#{source_name}.tar.gz")
      exclude_list = Pathname.new(tmpdir).join('exclude_list.txt')
      File.open(exclude_list, 'w') { |f| f << excludes.map { |e| e.to_s.sub(/\A\//, '') }.join("\n") }
      verbose_switch = Outback.verbose? ? 'v' : ''
      commandline = "tar -cz#{verbose_switch}pf #{archive_name} --exclude-from=#{exclude_list} --directory=/ #{source_dir.to_s.sub(/\A\//, '')}"
      logger.debug "executing command: #{commandline}"
      result = `#{commandline}`
      logger.debug "result: #{result}"
      logger.info "Archived directory #{path}"
      [SourceArchive.new(archive_name)]
    end
  end
end
