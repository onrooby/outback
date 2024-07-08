module Outback
  class Backup
    include Logging
    
    attr_reader :configuration, :name, :timestamp, :tmpdir
        
    def initialize(configuration)
      raise ArgumentError, "configuration required" unless configuration.is_a?(Outback::Configuration)
      @configuration = configuration
      @name = configuration.name
      @timestamp = Time.now.strftime(Outback::TIME_FORMAT)
    end
    
    def run!
      logger.info "Using working directory #{configuration.tmpdir}" if configuration.tmpdir
      @tmpdir = Dir.mktmpdir([name, timestamp], configuration.tmpdir)
      archives = create_archives
      logger.info "Created #{archives.size} archives"
      archives = process_archives(archives)
      logger.info "Processed #{archives.size} archives"
      store_archives(archives)
      purge_targets
    ensure
      FileUtils.remove_entry_secure(tmpdir)
    end
    
    [:sources, :processors, :targets].each do |collection|
      define_method(collection) { configuration.public_send(collection) }
    end
    
    private
    
    def create_archives
      sources.map { |source| source.create_archives(timestamp, tmpdir) }.flatten.compact
    end
    
    def process_archives(archives)
      processors.inject(archives) { |archives, processor| processor.process!(archives) }.flatten.compact
    end
    
    def store_archives(archives)
      targets.each do |target|
        begin
          target.put(archives)
        rescue => e
          logger.info "Error while storing to #{target}: #{e.inspect}"
          0
        end
      end
    end

    def purge_targets
      targets.each do |target|
        begin
          target.purge!
        rescue => e
          logger.info "Error while purging #{target}: #{e.inspect}"
        end
      end
    end
    
  end
end
