module AdventureRL
  module EventHandlers
    # An EventHandler can have multiple Event s.
    # You can subscribe an object to a specific Event using its name,
    # through the EventHandler.
    class EventHandler
      def initialize settings = {}
        @events = []
      end

      # Add an Event to this EventHandler.
      def add_event event
        Helpers::Error.error(
          "Passed `event' is not an instance of `Event'.",
          "Got `#{event.inspect}:#{event.class.name}'."
        )  unless (event.is_a? Events::Event)
        @events << event
      end
      alias_method :add, :add_event
      alias_method :<<,  :add_event

      # Subscribe an <tt>object</tt> to all Event s in this EventHandler.
      def subscribe object
        Helpers::Error.error(
          "Object `#{object.inspect}:#{object.class.name}' cannot subscribe",
          "to this EventHandler `#{self.inspect}:#{self.class.name}'."
        )  unless (valid_object? object)
        @events.each do |event|
          event.add_object object
        end
      end

      # Unsubscribe an <tt>object</tt> from all Event s in this EventHandler.
      def unsubscribe object
        @events.each do |event|
          event.remove_object object
        end
      end

      # Trigger the Event with the name <tt>event_name</tt>.
      # Returns <tt>true</tt> if the Event was found and <tt>false</tt> if not.
      # Optionally, additional <tt>args</tt> arguments can be passed,
      # which will be passed to the trigger methods on the Event s.
      def trigger event_name, *args
        event = @events.detect do |evnt|
          evnt.get_name == event_name
        end
        event.trigger *args  if (event)
        return !!event
      end

      private

        # Returns <tt>true</tt> if the passed <tt>object</tt> can be subscribed to this EventHandler,
        # and <tt>false</tt> if not.
        # This method should be overwritten to fit specific requirements.
        def valid_object? object
          return !!object
        end
    end
  end
end
