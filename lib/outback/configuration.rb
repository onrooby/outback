module Outback
  class Configuration
    
    @loaded = []

    class << self
      def add(configuration)
        raise ConfigurationError, "duplicate configuration #{configuration.name}" if loaded.any?(&its.name == configuration.name)
        loaded << configuration
      end
      
      def loaded
        @loaded
      end
      
      def [](name)
        loaded.detect { |configuration| configuration.name == name.to_s }
      end
      
      def reset
        @loaded = []
      end
    end

    attr_reader :name, :sources, :targets, :processors, :errors

    def initialize(name, &block)
      name = name.to_s
      raise ConfigurationError, "Illegal configuration name #{name.inspect}" unless name.match(/\A[a-z0-9]+\z/)
      @name = name
      @sources, @processors, @targets, @errors = [], [], [], []
      if block_given?
        if block.arity == 1 then yield(self) else instance_eval(&block) end
      end
      self.class.add(self)
    end

    def valid?
      errors.clear
      return error('no targets specified') if targets.empty?
      moving_targets = targets.select { |t| t.is_a?(DirectoryTarget) && t.move }
      return error('cannot define more than one moving target') if moving_targets.size > 1
      return error('moving target must be defined last') if moving_targets.first && moving_targets.first != targets.last
      true
    end
    
    def tmpdir(*args)
      if args.empty?
        @tmpdir
      elsif args.size == 1
        dir = Pathname.new(args.first).realpath
        raise ConfigurationError, "tmpdir #{dir} is not a directory" unless dir.directory?
        @tmpdir = dir
      else
        raise ConfigurationError, "tmpdir: wrong number of arguments(#{args.size} for 1)"
      end
    end

    protected

    def source(type, *args, &block)
      "Outback::#{type.to_s.classify}Source".constantize.configure(name, *args, &block).tap { |instance| sources << instance }
    end
    
    def processor(type, *args, &block)
      "Outback::#{type.to_s.classify}Processor".constantize.configure(name, *args, &block).tap { |instance| processors << instance }
    end
    
    def target(type, *args, &block)
      "Outback::#{type.to_s.classify}Target".constantize.configure(name, *args, &block).tap { |instance| targets << instance }
    end

    def error(message)
      errors << ConfigurationError.new(message)
      false
    end
  end
end
