module AdventureRL
  class Rectangle
    def initialize mask, args = {}
      default_settings = DEFAULT_SETTINGS.get :rectangle
      Helpers::Error.error "AdventureRL::Rectangle received '#{mask.class}' instead of AdventureRL::Mask"  unless (mask.is_a? Mask)
      mask.assign_to self
      @color   = args[:color]   || default_settings[:color]
      @z_index = args[:z_index] || default_settings[:z_index]
    end

    def draw
      corner = get_corner :left, :top
      Gosu.draw_rect(
        corner.x, corner.y,
        get_size(:width), get_size(:height),
        @color,
        @z_index
      )
    end
  end
end
