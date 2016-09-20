module Outback
    
  class AttrSetter
    def initialize(configurable)
      @configurable = configurable
      configurable.class.attributes.each do |name|
        meta_def(name) do |value|
          write_attribute(name, value)
        end
      end
    end
      
    def method_missing(name, *args, &block)
      @configurable.send(name, *args, &block)
    end

    private

    def write_attribute(name, value)
      @configurable.instance_variable_set "@#{name}", value
    end
  end

end
