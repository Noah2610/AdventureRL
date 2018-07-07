module AdventureRL
  class Window < Gosu::Window
    include Helpers::MethodHelper

    def initialize settings_arg = {}
      settings_arg = {}  unless (settings_arg)
      settings     = Settings.new(
        DEFAULT_SETTINGS.get(:window)
      ).merge(settings_arg)
      size         = settings.get(:size)
      Mask.new(
        position: Point.new(0, 0),
        size:     size,
        origin: {
          x: :left, y: :top
        },
        assign_to: self
      )
      @_deltatime      = Deltatime.new
      @_timing_handler = TimingHandler.new
      @_tick           = 0
      @_target_fps     = settings.get(:fps)
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
    alias_method :get_dt,  :get_deltatime

    # Returns the current game tick.
    # The tick is updated every time #update is called.
    def get_tick
      return @_tick
    end

    # Wrapper method for TimingHandler#set_timeout
    def set_timeout *args
      @_timing_handler.set_timeout *args
    end

    # Wrapper method for TimingHandler#set_interval
    def set_interval *args
      @_timing_handler.set_interval *args
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

    private

      def update
        @_timing_handler.update
        _increment_tick
        @_deltatime.update
      end

      def _increment_tick
        @_tick += 1
      end

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
