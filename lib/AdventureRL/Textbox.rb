module AdventureRL
  # This is similar to a Rectangle, but it can display text
  # with basic formatting.
  class Textbox < Rectangle
    DEFAULT_SETTINGS = Settings.new(
      text:       '',
      font_size:  24,
      font_name:  'MonoSpace',
      font_color: 0xff_ffffff,
      text_alignment: {
        x: :center,
        y: :center
      },
      border_padding: {
        x: 16,
        y: 8
      },
      border_color: 0xff_000000,
      border_size: {
        width:  0,
        height: 0
      },
      background_color: 0xff_000000,  # Background color
      z_index: 0,
      position: {
        x: 0,
        y: 0
      },
      size: {
        width:  256,
        height: 64
      },
      origin: {
        x: :left,
        y: :top
      }
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      @font_cache = {}  # This Hash will be filled with any loaded Gosu::Font (see #set_font_size)
      set_font_size @settings.get(:font_size)
      @text           = @settings.get :text
      @font_color     = @settings.get :font_color
      @text_alignment = @settings.get :text_alignment
      @border_padding = @settings.get :border_padding
      @border_color   = @settings.get :border_color
      @border_size    = @settings.get :border_size
      super @settings
      @color_original = @settings.get :background_color
    end

    def get_text
      return @text
    end

    def set_text text
      @text = text.to_s
    end

    # NOTE:
    # This method is expensive, because it loads a new Gosu::Font.
    # Call this sparingly.
    # Once a new Gosu::Font is created, it is cached,
    # wo when you resize to a previously used font it will not need to load a new Gosu::Font.
    def set_font_size size
      @font = @font_cache[size]
      return  if (@font)
      @font = Gosu::Font.new(
        size,
        name: @settings.get(:font_name)
      )
      @font_cache[size] = @font
    end

    # TODO: This doesn't really work, it still takes a while to draw a Font the first time; look into this.
    # Pass any amount of integers, which will each preload a new Gosu::Font,
    # with the size of the integer.
    def preload_font_sizes *sizes
      sizes.flatten.each do |size|
        Helpers::Error.error(
          "Expected size to be an Integer, but got",
          "`#{size.inspect}:#{size.class.name}'."
        )  unless (size.is_a? Integer)
        @font_cache[size] ||= Gosu::Font.new(
          size,
          name: @settings.get(:font_name)
        )
      end
    end

    def draw
      draw_border
      draw_background
      draw_text
      @color_temporary = nil
    end

    private

      def draw_border
        return  unless (has_border?)
        corner = get_corner :left, :top
        Gosu.draw_rect(
          corner.x, corner.y,
          get_size(:width), get_size(:height),
          @border_color,
          @z_index
        )
      end

      def draw_background
        pos  = get_position_for_background
        size = get_size_for_background
        Gosu.draw_rect(
          pos.x, pos.y,
          size[:width], size[:height],
          get_color,
          @z_index
        )
      end

      def draw_text
        pos = get_position_for_text
        rel = get_relative_for_text
        @font.draw_rel(
          @text,
          pos[:x], pos[:y], @z_index,
          rel[:x], rel[:y],
          1, 1,  # Scale
          @font_color
        )
      end

      def has_border?
        return @border_size.values.any? do |size|
          next size > 0
        end
      end

      def get_position_for_background
        corner = get_corner :left, :top
        return corner  unless (has_border?)
        pos = corner.dup
        pos.set_position(
          x: (corner.x + @border_size[:width]),
          y: (corner.y + @border_size[:height])
        )
        return pos
      end

      def get_size_for_background
        size = get_size
        return size  unless (has_border?)
        return {
          width:  (size[:width]  - (@border_size[:width]  * 2)),
          height: (size[:height] - (@border_size[:height] * 2))
        }
      end

      def get_position_for_text
        return [:x, :y].map do |axis|
          alignment = @text_alignment[axis]
          case alignment
          when :center
            pos = get_center axis
          else
            mult =  1  if ([:left,  :top].include?    alignment)
            mult = -1  if ([:right, :bottom].include? alignment)
            pos = (
              (@border_size[(axis == :x) ? :width : :height] * mult) +
              (@border_padding[axis] * mult) +
              get_side(alignment)
            )
          end
          next [axis, pos]
        end .to_h
      end

      def get_relative_for_text
        return [:x, :y].map do |axis|
          alignment = @text_alignment[axis]
          case alignment
          when :center
            pos = 0.5
          when :left, :top
            pos = 0.0
          when :right, :bottom
            pos = 1.0
          end
          next [axis, pos]
        end .to_h
      end
  end
end
