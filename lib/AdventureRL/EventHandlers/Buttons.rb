module AdventureRL
  module EventHandlers
    class Buttons < EventHandler
      def initialize
        super
        @pressable_buttons = []
        @events = get_events
      end

      # Add one or multiple button character(s) <tt>btns</tt>,
      # which will trigger the #on_button_press methods on subscribed objects,
      # when the given button is being pressed.
      # Instead of passing single alphanumeric strings / symbols,
      # you can pass hashes, whose keys will be passed to the #on_button_press methods,
      # when _any_ of its values are pressed.
      # Case-sensitive.
      def add_pressable_button *btns
        btns.flatten.each do |button|
          if (button.is_a?(Symbol) || button.is_a?(String))
            validate_button button
            btnid = Gosu.char_to_button_id button
            pressable_button = {
              name: button,
              ids:  [btnid]
            }
            @pressable_buttons << pressable_button  unless (@pressable_buttons.include? pressable_button)
          elsif (button.is_a?(Hash))
            button.each do |btn_name, btn_buttons|
              pressable_button = {
                name: btn_name,
                ids:  btn_buttons.map do |btn|
                  validate_button btn
                  next Gosu.char_to_button_id btn
                end
              }
              @pressable_buttons << pressable_button  unless (@pressable_buttons.include? pressable_button)
            end
          end
        end
      end
      alias_method :add_pressable_buttons, :add_pressable_button

      def button_down btnid
        trigger(
          :button_down,
          get_semantic_button_name(btnid),
          shift:   shift_button_pressed?,
          control: control_button_pressed?,
          alt:     alt_button_pressed?
        )
      end

      def button_up btnid
        trigger(
          :button_up,
          get_semantic_button_name(btnid),
          shift:   shift_button_pressed?,
          control: control_button_pressed?,
          alt:     alt_button_pressed?
        )
      end

      def update
        return  unless (get_pressable_buttons.any?)
        pressed_btns = get_pressable_buttons.map do |btn|
          next btn[:name]  if (btn[:ids].any? { |id| Gosu.button_down?(id) })
          next nil
        end .compact.uniq
        return  unless (pressed_btns.any?)
        pressed_btns.each do |btn|
          trigger(
            :button_press,
            btn,
            shift:   shift_button_pressed?,
            control: control_button_pressed?,
            alt:     alt_button_pressed?
          )
        end
      end

      def get_pressable_buttons
        return @pressable_buttons
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
          event.on_trigger do |object, btn_name, mod_keys|
            next  unless (object.methods.include? :on_button_down)
            if (object.method(:on_button_down).arity.abs == 2)
              object.on_button_down btn_name, mod_keys
            else
              object.on_button_down btn_name
            end
          end
          return event
        end

        def get_event_button_up
          event = Event.new(:button_up)
          event.on_trigger do |object, btn_name, mod_keys|
            next  unless (object.methods.include? :on_button_up)
            if (object.method(:on_button_up).arity.abs == 2)
              object.on_button_up btn_name, mod_keys
            else
              object.on_button_up btn_name
            end
          end
          return event
        end

        def get_event_button_press
          event = Event.new(:button_press)
          event.on_trigger do |object, btn_name, mod_keys|
            next  unless (object.methods.include? :on_button_press)
            if (object.method(:on_button_press).arity.abs == 2)
              object.on_button_press btn_name, mod_keys
            else
              object.on_button_press btn_name
            end
          end
          return event
        end

        def validate_button btn
          Helpers::Error.error(
            "Passed invalid button character. Expected a printable alphanumeric, but got",
            "`#{btn.inspect}:#{btn.class.name}'."
          )  unless (Gosu.char_to_button_id btn)
        end

        def get_semantic_button_name btnid
          btn_char = Gosu.button_id_to_char btnid
          return get_semantic_constant_button_name btnid  if (btn_char.empty?)
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

        # Returns <tt>true</tt> if either <tt>LEFT_CONTROL</tt> or <tt>RIGHT_CONTROL</tt> is pressed,
        # returns <tt>false</tt> otherwise.
        def control_button_pressed?
          return Gosu.button_down?(Gosu::KB_LEFT_CONTROL) || Gosu.button_down?(Gosu::KB_RIGHT_CONTROL)
        end

        # Returns <tt>true</tt> if either <tt>LEFT_ALT</tt> or <tt>RIGHT_ALT</tt> is pressed,
        # returns <tt>false</tt> otherwise.
        def alt_button_pressed?
          return Gosu.button_down?(Gosu::KB_LEFT_ALT) || Gosu.button_down?(Gosu::KB_RIGHT_ALT)
        end

        # Subscribing objects must be a Mask or have a Mask assigned to them.
        def valid_object? object
          ret = object.has_mask?  rescue false
          return ret
        end
    end
  end
end
