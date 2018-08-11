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
      @_camera = Camera.new(
        position: settings.get(:position),
        size:     settings.get(:size),
        origin:   settings.get(:origin)
      )
      Helpers::PipeMethods.pipe_methods_from self, to: @_camera
      @_target_fps     = settings.get(:fps)
      @_solids_manager = SolidsManager.new
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

    # Returns SolidsManager.
    def get_solids_manager
      return @_solids_manager
    end

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

    # If you use #button_down in your game,
    # be sure to call <tt>super</tt> at the beginning of the method,
    # to take advantage of the framework's button events.
    def button_down btnid
      EventHandlers::Buttons.button_down btnid
      Menu.button_down btnid
    end

    # If you use #button_up in your game,
    # be sure to call <tt>super</tt> at the beginning of the method,
    # to take advantage of the framework's button events.
    def button_up btnid
      EventHandlers::Buttons.button_up btnid
      Menu.button_up btnid
    end

    # Show cursor.
    def needs_cursor?
      return true
    end

    # Default #update method.
    # If you overwrite this, be sure to call <tt>super</tt>
    # in your method.
    def update
      @_camera.update
      @_solids_manager.update
      EventHandlers::Buttons.update
      Menu.update
    end

    # Default #draw method.
    # You might want to call <tt>super</tt>
    # if you overwrite this method.
    def draw
      @_camera.draw
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
