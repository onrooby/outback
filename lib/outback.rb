require 'pathname'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

require 's3'

require_relative 'vendor/string_ext'
require_relative 'vendor/numeric_ext'
require_relative 'vendor/enumerable_ext'
require_relative 'vendor/mysql'
require_relative 'vendor/metaclass'
require_relative 'vendor/methodphitamine'

require 'outback/version'
require 'outback/support/returning'
require 'outback/support/attr_setter'
require 'outback/support/configurable'
require 'outback/support/mysql_ext'
require 'outback/support/pathname_ext'
require 'outback/errors'
require 'outback/logging'
require 'outback/configuration'
require 'outback/archive'
require 'outback/source'
require 'outback/source_archive'
require 'outback/directory_source'
require 'outback/mysql_source'
require 'outback/processor'
require 'outback/encryption_processor'
require 'outback/target'
require 'outback/target_archive'
require 'outback/directory_target'
require 'outback/s3_target'
require 'outback/sftp_target'
require 'outback/backup'

module Outback
  TIME_FORMAT = '%Y%m%d%H%M%S'.freeze
  
  class << self
    %w(verbose silent).each do |method|
      attr_accessor method
      alias_method "#{method}?", method
    end
    
    def info(message)
      return if silent?
      puts message
      true
    end
    
    def debug(message)
      return unless verbose?
      return if silent?
      puts message
      true
    end
    
    def error(message, options = nil)
      return if silent?
      puts "Outback error: #{message}"
      false
    end
  end
end
