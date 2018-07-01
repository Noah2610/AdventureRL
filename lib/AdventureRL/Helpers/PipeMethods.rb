module AdventureRL
  module Helpers
    module PipeMethods
      # This method _pipes_ or forwards any methods called on the object
      # to the target object. It defines the <tt>method_missing</tt> method
      # on the origin object which calls the wanted method on the target object,
      # if it exists.
      def self.pipe_methods_from object_origin, args = {}
        object_target = args[:to]
        Error.error(
          "AdventureRL::Helpers::PipeMethods#pipe_methods_from requires a hash with the key :to and the value of the target object, where the methods should be piped to."
        )  unless (object_target)

        object_origin.define_singleton_method :method_missing do |method_name, *args|
          if    (object_target.methods.include?(method_name))
            return object_target.method(method_name).call(*args)
          elsif (object_target.methods.include?(:method_missing))
            return object_target.method(:method_missing).call(method_name, *args)
          else
            raise NoMethodError, "undefined method `#{method_name}' for #{self} (PIPED)"
          end
        end
      end
    end
  end
end
