require 'net/sftp'

module Outback
  class SftpTarget < Target
    
    attr_reader :host
    attr_setter :user, :password, :port, :path, :ttl, :ssh_opts
    
    def initialize(backup_name, host)
      super(backup_name)
      @host = host
    end
    
    def valid?
      host.present?
    end
    
    def to_s
      "sftp:#{user}@#{host}#{':' + port.to_s if port}:#{path}"
    end
    
    def put(archives)
      size = count = 0
      connect do
        archives.each do |archive|
          basename = archive.filename.basename.to_s
          upload_filename = path ? File.join(path, basename) : basename
          logger.debug "SftpTarget: storing #{archive.filename} in sftp://#{user}@#{host}#{':' + port.to_s if port}:#{upload_filename}"
          connection.upload!(archive.filename.to_s, upload_filename)
          size += archive.size
          count += 1
        end
      end
      logger.info "Uploaded #{count} archives (#{size} bytes) to #{self}"
      count
    end

    private
  
    def connect
      result = nil
      Net::SFTP.start(host, user, ssh_options) do |sftp|
        @connection = sftp
        result = yield
      end
      result
    ensure
      @connection = nil
    end
  
    def ssh_options
      options = ssh_opts || {}
      if password
        options[:password] = password
        options[:auth_methods] ||= %w[password]
      end
      options[:port] = port if port
      options
    end
    
    def list_all_archives
      connection.dir.entries(path).select(&:file?).map { |entry| build_archive(File.join(path, entry.name), entry.attributes.size.to_i) }
    end
    
    def unlink_archive!(archive)
      connection.remove!(archive.filename)
    end

  end
end
