module AdventureRL
  module EventHandlers
    class MouseButtons < EventHandler
      # This constant contains the IDs of all mouse buttons.
      MOUSE_BUTTON_IDS = [
        Gosu::MS_LEFT,
        Gosu::MS_MIDDLE,
        Gosu::MS_RIGHT,
        Gosu::MS_WHEEL_DOWN,
        Gosu::MS_WHEEL_UP
      ] .concat((0 .. 7).map do |n|
        next Gosu.const_get "MS_OTHER_#{n.to_s}"
      end)

      def initialize
        super
        @events = get_events
      end

      def button_down btnid
        return  unless (MOUSE_BUTTON_IDS.include? btnid)
        trigger :mouse_down, get_semantic_button_name(btnid)
      end

      def button_up btnid
        return  unless (MOUSE_BUTTON_IDS.include? btnid)
        trigger :mouse_up, get_semantic_button_name(btnid)
      end

      def update
        pressed_btnids = MOUSE_BUTTON_IDS.select do |btnid|
          next Gosu.button_down?(btnid)
        end
        return  unless (pressed_btnids.any?)
        pressed_btnids.each do |btnid|
          trigger :mouse_press, get_semantic_button_name(btnid)
        end
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
          event.on_trigger do |object, btn_name|
            next  unless (object.methods.include? :on_mouse_down)
            if (object.method(:on_mouse_down).arity > 0)
              object.on_mouse_down btn_name
            else
              object.on_mouse_down
            end  if (object.collides_with? get_mouse_point)
          end
          return event
        end

        def get_event_mouse_up
          event = Event.new(:mouse_up)
          event.on_trigger do |object, btn_name|
            next  unless (object.methods.include? :on_mouse_up)
            if (object.method(:on_mouse_up).arity > 0)
              object.on_mouse_up btn_name
            else
              object.on_mouse_up
            end  if (object.collides_with? get_mouse_point)
          end
          return event
        end

        def get_event_mouse_press
          event = Event.new(:mouse_press)
          event.on_trigger do |object, btn_name|
            next  unless (object.methods.include? :on_mouse_press)
            if (object.method(:on_mouse_press).arity > 0)
              object.on_mouse_press btn_name
            else
              object.on_mouse_press
            end  if (object.collides_with? get_mouse_point)
          end
          return event
        end

        def get_mouse_point
          window = Window.get_window
          return Point.new(window.mouse_x, window.mouse_y)
        end

        def get_semantic_button_name btnid
          return Gosu.constants.map do |constant_name|
            constant = Gosu.const_get constant_name
            next constant_name.to_s.sub(/^MS_/,'').downcase.to_sym  if (constant == btnid && constant_name.match?(/_/))
            next nil
          end .compact.first
        end

        # Subscribing objects must be a Mask or have a Mask assigned to them.
        def valid_object? object
          ret = object.has_mask?  rescue false
          return ret
        end
    end
  end
end
