module AdventureRL
  module EventHandlers
    class MouseButtons < Buttons
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

      def button_down btnid
        return  unless (MOUSE_BUTTON_IDS.include? btnid)
        trigger(
          :mouse_down,
          get_semantic_button_name(btnid),
          shift:   shift_button_pressed?,
          control: control_button_pressed?,
          alt:     alt_button_pressed?
        )
      end

      def button_up btnid
        return  unless (MOUSE_BUTTON_IDS.include? btnid)
        trigger(
          :mouse_up,
          get_semantic_button_name(btnid),
          shift:   shift_button_pressed?,
          control: control_button_pressed?,
          alt:     alt_button_pressed?
        )
      end

      def update
        pressed_btnids = MOUSE_BUTTON_IDS.select do |btnid|
          next Gosu.button_down?(btnid)
        end
        return  unless (pressed_btnids.any?)
        pressed_btnids.each do |btnid|
          trigger(
            :mouse_press,
            get_semantic_button_name(btnid),
            shift:   shift_button_pressed?,
            control: control_button_pressed?,
            alt:     alt_button_pressed?
          )
        end
      end

      def add_pressable_button *args
        Helpers::Error.error(
          "Cannot add pressable button(s) to #{self.class.name}."
        )
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
          event = Events::Mouse.new(:mouse_down)
          event.on_trigger do |object, btn_name, mod_keys|
            next  unless (object.methods.include?(:on_mouse_down) && object.collides_with?(get_mouse_point))
            case object.method(:on_mouse_down).arity.abs
            when 0
              object.on_mouse_down
            when 1
              object.on_mouse_down btn_name
            when 2
              object.on_mouse_down btn_name, mod_keys
            end
          end
          return event
        end

        def get_event_mouse_up
          event = Events::Mouse.new(:mouse_up)
          event.on_trigger do |object, btn_name, mod_keys|
            next  unless (object.methods.include?(:on_mouse_up) && object.collides_with?(get_mouse_point))
            case object.method(:on_mouse_up).arity.abs
            when 0
              object.on_mouse_up
            when 1
              object.on_mouse_up btn_name
            when 2
              object.on_mouse_up btn_name, mod_keys
            end
          end
          return event
        end

        def get_event_mouse_press
          event = Events::Mouse.new(:mouse_press)
          event.on_trigger do |object, btn_name, mod_keys|
            next  unless (object.methods.include?(:on_mouse_press) && object.collides_with?(get_mouse_point))
            case object.method(:on_mouse_press).arity.abs
            when 0
              object.on_mouse_press
            when 1
              object.on_mouse_press btn_name
            when 2
              object.on_mouse_press btn_name, mod_keys
            end
          end
          return event
        end

        def get_mouse_point
          window = Window.get_window
          return nil  unless (window)
          return Point.new(window.mouse_x, window.mouse_y)
        end

        def get_semantic_button_name btnid
          return Gosu.constants.map do |constant_name|
            constant = Gosu.const_get constant_name
            next constant_name.to_s.sub(/^MS_/,'').downcase.to_sym  if (constant == btnid && constant_name.match?(/_/))
            next nil
          end .compact.first
        end
    end
  end
end
