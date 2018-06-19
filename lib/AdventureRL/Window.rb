module AdventureRL
  class Window < Gosu::Window
    include Helpers::Method

    def initialize args = {}
      default_settings = DEFAULT_SETTINGS.get :window
      size = args[:size] || default_settings[:size]
      @mask = Mask.new(
        position: Point.new(0, 0),
        size:     size,
        origin: {
          x: :left, y: :top
        }
      )
      @window_last_update_at = nil
      _set_last_update_at
      @window_tick = 0
      super(
        get_size(:width), get_size(:height),
        fullscreen:      !!(args[:fullscreen] || default_settings[:fullscreen]),
        update_interval: (args[:fps] || default_settings[:fps])
      )
      self.caption = args[:caption] || default_settings[:caption]
      _call_setup_method args
    end

    def setup args
      # This method can be overwritten by user,
      # and will be called after #initialize
    end

    def get_mask
      return @mask
    end

    def get_size target = :all
      return get_mask.get_size target
    end

    def get_center target = :all
      return get_mask.get_center target
    end

    def get_fps
      return Gosu.fps
    end

    def get_deltatime
      diff_in_secs = _get_elapsed_seconds - @window_last_update_at
      return diff_in_secs
    end

    def get_tick
      return @window_tick
    end

    private

    def update
      _increment_tick
      _set_last_update_at
    end

    def _increment_tick
      @window_tick += 1
    end

    def _set_last_update_at
      @window_last_update_at = _get_elapsed_seconds
    end

    def _get_elapsed_seconds
      return Gosu.milliseconds.to_f / 1000.0
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
