require 'optparse'

module Outback
  module CLI
    DEFAULT_CONFIGURATION_FILE = '/etc/outback.conf'
    
    class << self
      def invoke
        options = {}
        option_parser = OptionParser.new do |p|
          p.banner = "Usage: outback [configfile]"
          p.on('-c', '--config NAME', 'execute only the backup identified by NAME') do |name|
            options[:config] = name.to_s
          end
          p.on('-v', '--verbose', 'be talky') do
            Outback.verbose = true
          end
          p.on('-s', '--silent', 'be silent') do
            Outback.silent = true
          end
          p.on('-l', '--list', 'list configurations, then exit') do
            options[:list] = true
          end
          p.on('-t', '--test', 'test configurations, then exit') do
            options[:test] = true
          end
          p.on_tail("-h", "--help", "Show this message") do
            puts p
            exit
          end
          p.on_tail("--version", "Show version") do
            Outback.info "Outback #{Outback::VERSION}"
            exit
          end
        end
        option_parser.parse!
        Outback::Configuration.reset
        config_file = if ARGV.first
          ARGV.first.start_with?('/') ? ARGV.first : File.join(Dir.pwd, ARGV.first)
        else
          DEFAULT_CONFIGURATION_FILE
        end
        begin
          load config_file
        rescue ConfigurationError => conf_error
          Outback.error "Configuration Error! #{conf_error}"
          exit(1)
        rescue Exception => e
          regexp = /#{Regexp.escape(config_file)}:(\d+)/
          match_data = nil
          if e.backtrace.detect { |line| match_data = line.match(regexp) }
            line_info = " on line #{match_data.captures.first}"
          end
          Outback.error "Error loading config file: #{e}#{line_info}"
          exit(1)
        end
        if Outback::Configuration.loaded.empty?
          Outback.info 'no configuration could be loaded'
          exit(1)
        end
        invalid_configs = Outback::Configuration.loaded.reject(&:valid?)
        invalid_configs.each do |configuration|
          Outback.error "configuration #{configuration.name}: #{configuration.errors}"
        end
        exit(1) unless invalid_configs.empty?
        if options[:test]
          Outback.info 'configurations OK'
          exit(0)
        end
        if options[:list]
          Outback.info "available configurations:"
          Outback::Configuration.loaded.each { |c| puts c.name }
          exit(0)
        end
        configurations = if options[:config]
          unless config = Outback::Configuration[options[:config]]
            Outback.error "configuration '#{options[:config]}' not found"
            exit(1)
          end
          [config]
        else
          Outback::Configuration.loaded
        end
        configurations.each { |configuration| Outback::Backup.new(configuration).run! }
      end
    
    end
    
  end  
end
