module AdventureRL
  class Button < Textbox
    DEFAULT_SETTINGS = Settings.new(
      active_color:      0xff_cc8822,
      hover_colow:       0xff_888888,
      pressable:         false,
      click_on_mouse_up: false
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings
      @colors = {
        active: @settings.get(:active_color),
        hover:  @settings.get(:hover_colow),
      }
      @pressable         ||= @settings.get :pressable
      @click_on_mouse_up ||= @settings.get :click_on_mouse_up
      @click_on_mouse_up ||= false  if (@pressable)
    end

    def get_menu
      layer = get_layer
      return layer  if (layer.is_a? Menu)
      return nil
    end

    def on_mouse_down
      return  if (is_pressable?)
      set_color @colors[:active]
      click  if (!@click_on_mouse_up && methods.include?(:click))
    end

    def on_mouse_up
      return  if (is_pressable?)
      reset_color
      click  if (@click_on_mouse_up && methods.include?(:click))
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
