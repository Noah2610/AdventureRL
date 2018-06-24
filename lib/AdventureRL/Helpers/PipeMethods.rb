module AdventureRL
  module Helpers
    module PipeMethods
      def self.pipe_methods_from object_origin, args = {}
        object_target = args[:to]
        AdventureRL::Helpers::Error.error(
          "AdventureRL::Helpers::PipeMethods#pipe_methods_from requires a hash with the key :to and the value of the target object, where the methods should be piped to."
        )  unless (object_target)

        object_origin.class.send :define_method, :method_missing do |method_name, *args|
          if (object_target.methods.include? method_name)
            return object_target.method(method_name).call(*args)
          else
            raise NoMethodError, "undefined method `#{method_name}' for #{self} (PIPED)"
          end
        end
      end
    end
  end
end
