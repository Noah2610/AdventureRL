module AdventureRL
  module Helpers
    module Method
      private

      def method_exists? method_name
        return methods.include? method_name
      end

      def method_takes_arguments? method_name
        return nil  unless (method_exists?(method_name))
        meth = method method_name
        return meth.arity.abs > 0
      end
    end
  end
end
