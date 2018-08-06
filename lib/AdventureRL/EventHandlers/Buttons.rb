module AdventureRL
  module EventHandlers
    class Buttons < EventHandler
      def initialize
        super
        @pressable_button_ids = []
        @events = get_events
      end

      # Add a button character <tt>btn_char</tt>,
      # which will trigger the #on_button_press methods on subscribed objects,
      # when the given button is being pressed.
      # Case-sensitive.
      def add_pressable_button btn_char
        btnid = Gosu.char_to_button_id btn_char
        Helpers::Error.error(
          "Passed invalid btn_char. Expected a printable alphanumeric, but got",
          "`#{btn_char.inspect}:#{btn_char.class.name}'."
        )  unless (btnid)
        @pressable_button_ids << {
          id:    btnid,
          shift: shift_button_pressed?
        }
      end

      def button_down btnid
        trigger :button_down, get_semantic_button_name(btnid)
      end

      def button_up btnid
        trigger :button_up, get_semantic_button_name(btnid)
      end

      def update
        pressed_btnids = get_pressable_button_ids.map do |btnid, shift|
          next btnid  if (
            Gosu.button_down?(btnid) &&
            (!shift || (shift && shift_button_pressed?))
          )
        end
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
            next constant_name.to_s.sub(/^(KB_|MS_|GP_)/,'').downcase.to_sym  if (constant == btnid && constant_name.match?(/_/))
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
