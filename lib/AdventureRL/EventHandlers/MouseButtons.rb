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
        btn_name = get_semantic_button_name(btnid)
        trigger :mouse_down, btn_name
      end

      def button_up btnid
        return  unless (MOUSE_BUTTON_IDS.include? btnid)
        trigger :mouse_up, get_semantic_button_name(btnid)
      end

      def update
        pressed_btnids = MOUSE_BUTTON_IDS.map do |btnid|
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
          event.on_trigger do |object, btnid|
            next  unless (object.methods.include? :on_mouse_down)
            object.on_mouse_down btnid  if (object.collides_with? get_mouse_point)
          end
          return event
        end

        def get_event_mouse_up
          event = Event.new(:mouse_up)
          event.on_trigger do |object, btnid|
            next  unless (object.methods.include? :on_mouse_up)
            object.on_mouse_up btnid  if (object.collides_with? get_mouse_point)
          end
          return event
        end

        def get_event_mouse_press
          event = Event.new(:mouse_press)
          event.on_trigger do |object, btnid|
            next  unless (object.methods.include? :on_mouse_press)
            object.on_mouse_press btnid  if (object.collides_with? get_mouse_point)
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
            next constant_name.to_s.sub(/^MS_/,'').downcase.to_sym  if (constant == btnid)  if (constant_name.match?(/_/))
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
