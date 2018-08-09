module AdventureRL
  class Window < Gosu::Window
    include Helpers::MethodHelper

    @@WINDOW = nil

    class << self
      # This returns the current Window.
      # As there should always only be one instance of Window,
      # this should be fine.
      def get_window
        return @@WINDOW
      end
    end

    def initialize settings_arg = {}
      @@WINDOW = self
      settings_arg = {}  unless (settings_arg)
      settings = Settings.new(
        DEFAULT_SETTINGS.get(:window)
      ).merge(settings_arg)
      @_layer = Layer.new(
        position: settings.get(:position),
        size:     settings.get(:size),
        origin:   settings.get(:origin)
      )
      Helpers::PipeMethods.pipe_methods_from self, to: @_layer
      @_target_fps                  = settings.get(:fps)
      @_deltatime                   = Deltatime.new
      @_timing_handler              = TimingHandler.new
      @_buttons_event_handler       = EventHandlers::Buttons.new
      @_mouse_buttons_event_handler = EventHandlers::MouseButtons.new
      @_solids_manager              = SolidsManager.new
      super(
        get_size(:width), get_size(:height),
        fullscreen:      settings.get(:fullscreen),
        update_interval: _get_update_inteval_from_fps(@_target_fps)
      )
      self.caption = settings.get(:caption)
      _call_setup_method settings_arg
    end

    # This method can be overwritten by user,
    # and will be called after <tt>#initialize</tt>.
    def setup args
    end

    # Returns the current FPS.
    # This is just a wrapper method around <tt>Gosu.fps</tt>
    # to maintain the design pattern with <tt>get_*</tt> methods.
    def get_fps
      return Gosu.fps
    end

    # Returns the expected FPS.
    # These were passed to <tt>#initialize</tt> in the settings.
    def get_target_fps
      return @_target_fps
    end

    # Returns the value of the last calculated deltatime.
    def get_deltatime
      return @_deltatime.get_deltatime
    end
    alias_method :get_dt, :get_deltatime

    # Returns EventHandlers::Buttons.
    def get_buttons_event_handler
      return @_buttons_event_handler
    end

    # Wrapper method for EventHandlers::Buttons#add_pressable_button.
    def add_pressable_button btn_char
      get_buttons_event_handler.add_pressable_button btn_char
    end

    # Returns EventHandlers::MouseButtons.
    def get_mouse_buttons_event_handler
      return @_mouse_buttons_event_handler
    end

    # Returns SolidsManager.
    def get_solids_manager
      return @_solids_manager
    end

    # Resets Deltatime.
    def reset_deltatime
      @_deltatime.reset
    end
    alias_method :reset_dt, :get_deltatime

    # Wrapper method around Gosu::Window#fullscreen?,
    # just to follow the design pattern.
    def is_fullscreen?
      return fullscreen?
    end

    # Wrapper method around Gosu::Window#fullscreen=,
    # just to follow the design pattern.
    def set_fullscreen state
      self.fullscreen = !!state
    end

    # Toggle beteween fullscreen and windowed states.
    def toggle_fullscreen
      set_fullscreen !is_fullscreen?
    end

    # Wrapper method for TimingHandler#set_timeout
    def set_timeout *args, &block
      @_timing_handler.set_timeout *args, &block
    end

    # Wrapper method for TimingHandler#set_interval
    def set_interval *args, &block
      @_timing_handler.set_interval *args, &block
    end

    # Wrapper method for TimingHandler#remove_timeout
    def remove_timeout *args
      @_timing_handler.remove_timeout *args
    end
    alias_method :clear_timeout, :remove_timeout

    # Wrapper method for TimingHandler#remove_interval
    def remove_interval *args
      @_timing_handler.remove_interval *args
    end
    alias_method :clear_interval, :remove_interval

    # If you use #button_down in your game,
    # be sure to call <tt>super</tt> at the beginning of the method,
    # to take advantage of the framework's button events.
    def button_down btnid
      @_buttons_event_handler.button_down       btnid
      @_mouse_buttons_event_handler.button_down btnid
    end

    # If you use #button_up in your game,
    # be sure to call <tt>super</tt> at the beginning of the method,
    # to take advantage of the framework's button events.
    def button_up btnid
      @_buttons_event_handler.button_up       btnid
      @_mouse_buttons_event_handler.button_up btnid
    end

    # Show cursor.
    def needs_cursor?
      return true
    end

    # Default #update method.
    # If you overwrite this, be sure to call <tt>super</tt>
    # in your method.
    def update
      @_layer.update
      @_solids_manager.update
      @_buttons_event_handler.update
      @_mouse_buttons_event_handler.update
      @_timing_handler.update
      @_deltatime.update
    end

    # Default #draw method.
    # You might want to call <tt>super</tt>
    # if you overwrite this method.
    def draw
      @_layer.draw
      # TODO
      #@_solids_manager.draw
    end

    private

      def _get_update_inteval_from_fps fps
        return (1.0 / fps.to_f) * 1000
      end

      def _call_setup_method args
        return  unless (method_exists?(:setup))
        if (method_takes_arguments?(:setup))
          setup args
        else
          setup
        end
      end
  end
end
