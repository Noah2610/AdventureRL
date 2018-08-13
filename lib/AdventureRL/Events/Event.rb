module AdventureRL
  module Events
    class Event
      def initialize name
        @name           = name
        @objects        = []
        @trigger_method = nil
      end

      # Returns the <tt>name</tt> of the Event.
      def get_name
        return @name
      end

      # Returns the objects that subscribed to this Event. (see #add_object)
      def get_objects
        return @objects
      end

      # Add one or multiple <tt>object</tt>(s) to this Event.
      def add_object object
        [object].flatten.each do |obj|
          Helpers::Error.error(
            "Object `#{obj.inspect}:#{obj.class.name}' cannot be given",
            "to this Event `#{self.inspect}:#{self.class.name}'."
          )  unless (valid_object? obj)
          @objects << obj  unless (@objects.include? obj)
        end
      end
      alias_method :add, :add_object
      alias_method :<<,  :add_object

      # Remove one or multiple <tt>object</tt>(s) from this Event.
      def remove_object object
        [object].flatten.each do |obj|
          @objects.delete obj
        end
      end

      # Pass a block, which will be called when this Event is triggered (see #trigger).
      # The passed block takes an argument, which is a subscribed object.
      def on_trigger &block
        Helpers::Error.error(
          "Method #on_trigger needs a block to be passed."
        )  unless (block_given?)
        @trigger_method = block
      end

      # The block defined with #on_trigger will be called
      # for every subscribed object.
      # Optionally, additional <tt>args</tt> arguments can be passed,
      # which will be passed to the trigger method.
      def trigger *args
        get_objects.each do |object|
          @trigger_method.call object, *args
        end
      end

      private

        # Returns <tt>true</tt> if the passed <tt>object</tt> can be given to this Event,
        # and <tt>false</tt> if not.
        # This method should be overwritten to fit specific requirements.
        def valid_object? object
          return !!object
        end
    end
  end
end
