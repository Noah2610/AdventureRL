module AdventureRL
  class Rectangle < Mask
    include Helpers::Error

    # Default settings for Rectangle.
    # <tt>settings</tt> passed to #new take precedence.
    DEFAULT_SETTINGS = Settings.new(
      color:   0xff_ffffff,
      z_index: 0
    )

    # Initialize with a Settings object <tt>settings</tt>.
    # This must include a <tt>:mask</tt> key with a Mask object.
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings
      @color          = nil
      @color_original = @settings.get(:color)
      @z_index        = @settings.get(:z_index)
    end

    def set_color color
      @color = color
    end

    def get_color
      return @color || @color_original
    end

    def reset_color
      @color = nil
    end

    def draw
      corner = get_corner :left, :top
      Gosu.draw_rect(
        corner.x, corner.y,
        get_size(:width), get_size(:height),
        get_color,
        @z_index
      )
    end

  end
end
