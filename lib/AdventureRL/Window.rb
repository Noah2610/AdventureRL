module AdventureRL
  class Window < Gosu::Window
    include Helpers::Method

    def initialize args = {}
      default_settings = DEFAULT_SETTINGS.get :window
      @window_size = args[:size] || default_settings[:size]
      @window_tick = 0
      @window_last_update_at = nil
      _set_last_update_at
      super(
        @window_size[:width], @window_size[:height],
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

    def get_size target = :all
      target = target.to_sym
      if    (target == :all)
        return @window_size
      elsif (@window_size.keys.include?(target))
        return @window_size[target]
      else
        return nil
      end
    end

    def get_center_point
      # TODO: return mask.get_center_point or something
      #return Point.new 
    end

    def get_fps
      return Gosu.fps
    end

    def get_deltatime
      diff_in_secs = _get_elapsed_seconds - @window_last_update_at
      return diff_in_secs
    end

    def get_tick
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
