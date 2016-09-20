module StringExt

  def classify
    split('/').map { |c| c.split('_').map(&:capitalize).join }.join('::')
  end

  def constantize
    self.split("::").inject(Module) {|acc, val| acc.const_get(val)}
  end

  unless String.method_defined?(:blank?)
    def blank?
      empty? || strip.empty?
    end
  end

end

String.include StringExt
