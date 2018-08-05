module AdventureRL
  module EventHandlers
    class MouseButtons < EventHandler
      def initialize
        super
        @events = get_events
      end

      private

        def get_events
          return [
            get_event_mouse_down,
            get_event_mouse_up,
            get_event_mouse_press
          ]
        end

        def get_event_mouse_down
          event = Event.new(:mouse_down)
          event.on_trigger do |object, btnid|
            object.on_mouse_down btnid  if (object.methods.include? :on_mouse_down)
          end
          return event
        end

        def get_event_mouse_up
          event = Event.new(:mouse_up)
          event.on_trigger do |object|
            object.on_mouse_up btnid  if (object.methods.include? :on_mouse_up)
          end
          return event
        end

        def get_event_mouse_press
          event = Event.new(:mouse_press)
          event.on_trigger do |object|
            object.on_mouse_press btnid  if (object.methods.include? :on_mouse_press)
          end
          return event
        end

        # Subscribing objects must be a Mask or have a Mask assigned to them.
        def valid_object? object
          ret = object.has_mask?  rescue false
          return ret
        end
    end
  end
end
