module AdventureRL
  module EventHandlers
    class Buttons < EventHandler
      def initialize
        super
        @pressable_button_ids = []
        @events = get_events
      end

      # Add one or multiple button character <tt>btn_chars</tt>,
      # which will trigger the #on_button_press methods on subscribed objects,
      # when the given button is being pressed.
      # Case-sensitive.
      def add_pressable_button *btn_chars
        btn_chars.flatten.each do |btn_char|
          btnid = Gosu.char_to_button_id btn_char
          Helpers::Error.error(
            "Passed invalid btn_char. Expected a printable alphanumeric, but got",
            "`#{btn_char.inspect}:#{btn_char.class.name}'."
          )  unless (btnid)
          pressable_button = {
            id:    btnid,
            shift: btn_char.upper?
          }
          @pressable_button_ids << pressable_button  unless (@pressable_button_ids.include? pressable_button)
        end
      end

      def button_down btnid
        trigger :button_down, get_semantic_button_name(btnid)
      end

      def button_up btnid
        trigger :button_up, get_semantic_button_name(btnid)
      end

      def update
        pressed_btnids = get_pressable_button_ids.map do |pressable_button|
          next pressable_button[:id]  if (
            Gosu.button_down?(pressable_button[:id]) &&
            (!pressable_button[:shift] || (pressable_button[:shift] && shift_button_pressed?))
          )
          next nil
        end .compact.uniq
        return  unless (pressed_btnids.any?)
        pressed_btnids.each do |btnid|
          trigger :button_press, get_semantic_button_name(btnid)
        end
      end

      def get_pressable_button_ids
        return @pressable_button_ids
      end

      private

        def get_events
          return [
            get_event_button_down,
            get_event_button_up,
            get_event_button_press
          ]
        end

        def get_event_button_down
          event = Event.new(:button_down)
          event.on_trigger do |object, btn_name|
            next  unless (object.methods.include? :on_button_down)
            object.on_button_down btn_name
          end
          return event
        end

        def get_event_button_up
          event = Event.new(:button_up)
          event.on_trigger do |object, btn_name|
            next  unless (object.methods.include? :on_button_up)
            object.on_button_up btn_name
          end
          return event
        end

        def get_event_button_press
          event = Event.new(:button_press)
          event.on_trigger do |object, btn_name|
            next  unless (object.methods.include? :on_button_press)
            object.on_button_press btn_name
          end
          return event
        end

        def get_semantic_button_name btnid
          btn_char = Gosu.button_id_to_char btnid
          return get_semantic_constant_button_name btnid  if (btn_char.empty?)
          btn_char.upcase!  if (shift_button_pressed?)
          return btn_char.to_sym
        end

        def get_semantic_constant_button_name btnid
          return Gosu.constants.map do |constant_name|
            constant = Gosu.const_get constant_name
            if (constant == btnid && constant_name.match?(/_/))
              name = constant_name.to_s.sub(/^(KB_|MS_|GP_)/,'').downcase
              name.upcase!  if (shift_button_pressed?)
              next name.to_sym
            end
            next nil
          end .compact.first
        end

        # Returns <tt>true</tt> if either <tt>LEFT_SHIFT</tt> or <tt>RIGHT_SHIFT</tt> is pressed,
        # returns <tt>false</tt> otherwise.
        def shift_button_pressed?
          return Gosu.button_down?(Gosu::KB_LEFT_SHIFT) || Gosu.button_down?(Gosu::KB_RIGHT_SHIFT)
        end

        # Subscribing objects must be a Mask or have a Mask assigned to them.
        def valid_object? object
          ret = object.has_mask?  rescue false
          return ret
        end
    end
  end
end
