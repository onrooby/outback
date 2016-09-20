module Outback
#  module Support
    module Returning
      def returning(value, &block)
        value.tap(&block)
      end
    end
#  end
end

Object.send(:include, Outback::Returning)