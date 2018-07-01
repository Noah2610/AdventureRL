module AdventureRL
  class Window < Gosu::Window
    include Helpers::MethodHelper

    def initialize settings = {}
      default_settings = DEFAULT_SETTINGS.get :window
      size = settings[:size] || default_settings[:size]

      Mask.new(
        position: Point.new(0, 0),
        size:     size,
        origin: {
          x: :left, y: :top
        },
        assign_to: self
      )

      #AdventureRL::Helpers::PipeMethods.pipe_methods_from self, to: @_mask  # Calls any missing methods on @_mask
      @_last_update_at = nil
      _set_last_update_at
      @_deltatime = nil
      _set_deltatime
      @_tick = 0
      @_target_fps = settings[:fps] || default_settings[:fps]
      super(
        get_size(:width), get_size(:height),
        fullscreen:      !!(settings[:fullscreen] || default_settings[:fullscreen]),
        update_interval: _get_update_inteval_from_fps(@_target_fps)
      )
      self.caption = settings[:caption] || default_settings[:caption]
      _call_setup_method settings
    end

    def setup args
      # This method can be overwritten by user,
      # and will be called after #initialize
    end

    def get_fps
      return Gosu.fps
    end

    def get_target_fps
      return @_target_fps
    end

    def get_deltatime
      return @_deltatime
    end

    def get_tick
      return @_tick
    end

    private

    def update
      _increment_tick
      _set_deltatime
      _set_last_update_at
    end

    def _increment_tick
      @_tick += 1
    end

    def _set_deltatime
      diff_in_secs = _get_elapsed_seconds - @_last_update_at
      @_deltatime = diff_in_secs
    end

    def _get_elapsed_seconds
      return Gosu.milliseconds.to_f / 1000.0
    end

    def _set_last_update_at
      @_last_update_at = _get_elapsed_seconds
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
