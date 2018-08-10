module AdventureRL
  class Button < Textbox
    DEFAULT_SETTINGS = Settings.new(
      color_active: 0xff_cc8822,
      color_hover:  0xff_888888,
      pressable:    false,
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings
      @colors = {
        active: @settings.get(:color_active),
        hover:  @settings.get(:color_hover),
      }
      @pressable = @settings.get :pressable
    end

    def on_mouse_down
      return  if (is_pressable?)
      set_color @colors[:active]
    end

    def on_mouse_up
      return  if (is_pressable?)
      reset_color
    end

    def on_mouse_press
      return  unless (is_pressable?)
      set_temporary_color @colors[:active]
    end

    private

      def is_pressable?
        return !!@pressable
      end
  end
end
