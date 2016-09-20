require 'openssl'
require 'open3'

module Outback
  class EncryptionProcessor < Processor

    attr_setter :password, :cipher

    def cipher
      @cipher ||= 'aes-256-cbc'
    end
    
    def to_s
      "encryption:#{cipher}"
    end

    private
    
    def process_archive!(archive)
      result = nil
      outfile = Pathname.new("#{archive.filename}.enc")
      logger.debug "Encrypting #{archive} with #{self}"
      Open3.popen3("openssl enc -#{cipher} -pass stdin -in #{archive.filename} -out #{outfile}") do |stdin, stdout, stderr, wait_thr|
        stdin << password
        stdin.close
        result = wait_thr.value
      end
      raise ProcessingError, "error processing archive #{archive} in #{self}" unless result.success?
      raise ProcessingError, "outfile #{outfile} not found" unless outfile.file?
      archive.unlink
      SourceArchive.new(outfile)
    end
  end
end
