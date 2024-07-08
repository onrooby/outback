module Kernel
  protected

  def its() It.new end
  alias _its its
  alias _it its
  alias it its # RUBY34: deprecated method
end

class It < BasicObject
  
  undef_method(*(instance_methods - [:__id__, :__send__]))
  
  def initialize
    @methods = []
  end
 
  def method_missing(*args, **kwargs, &block)
    @methods << [args, kwargs, block] unless args == [:respond_to?, :to_proc]
    self
  end
 
  def to_proc
    ::Kernel.lambda do |obj|
      @methods.inject(obj) { |current, (args, kwargs, block)| current.send(*args, **kwargs, &block) }
    end
  end
end
