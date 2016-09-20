module Kernel
  protected
  def it() It.new end
  alias its it
end
 
class It < BasicObject
  
  undef_method(*(instance_methods - [:__id__, :__send__]))
  
  def initialize
    @methods = []
  end
 
  def method_missing(*args, &block)
    @methods << [args, block] unless args == [:respond_to?, :to_proc]
    self
  end
 
  def to_proc
    ::Kernel.lambda do |obj|
      @methods.inject(obj) { |current, (args,block)| current.send(*args, &block) }
    end
  end
end
