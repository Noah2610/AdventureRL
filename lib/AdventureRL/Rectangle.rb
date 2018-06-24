module AdventureRL
  class Rectangle
    def initialize mask, args = {}
      default_settings = DEFAULT_SETTINGS.get :rectangle
      Helpers::Error.error "AdventureRL::Rectangle received '#{mask.class}' instead of AdventureRL::Mask"  unless (mask.is_a? Mask)
      mask.assign_to self
      @color_original = args[:color]   || default_settings[:color]
      @z_index        = args[:z_index] || default_settings[:z_index]
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
