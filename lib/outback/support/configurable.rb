module Outback
  module Configurable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def attributes
        @attributes ||= []
      end
      
      def configure(*args, &block)
        returning new(*args) do |instance|
          if block_given?
            if block.arity == 1 then yield(instance.attr_setter) else instance.attr_setter.instance_eval(&block) end
          end
        end
      end
      
      def attr_setter(*names)
        attributes.concat(names).uniq!
        names.each { |name| attr_reader name }
      end
      
    end
    
    def attr_setter
      @attr_setter ||= AttrSetter.new(self)
    end
    
  end
end
