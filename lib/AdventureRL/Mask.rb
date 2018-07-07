module AdventureRL
  class Mask
    # Default settings for Mask.
    # Are superseded by settings passed to <tt>#initialize</tt>.
    DEFAULT_SETTINGS = Settings.new({
      #position: Point.new(0, 0),
      position: {
        x: 0,
        y: 0
      },
      size: {
        width:  64,
        height: 64
      },
      origin: {
        x: :left,
        y: :top
      },
      assign_to: nil
    })

    # Pass settings Hash or <tt>AdventureRL::Settings</tt> as argument.
    # Supersedes <tt>DEFAULT_SETTINGS</tt>.
    def initialize settings_arg = {}
      settings  = DEFAULT_SETTINGS.merge settings_arg
      set_position_from settings.get(:position)
      @size     = settings.get(:size)
      @origin   = settings.get(:origin)
      assign_to settings.get(:assign_to)  if (settings.get(:assign_to))
    end

    def assign_to object
      Helpers::PipeMethods.pipe_methods_from object, to: self
    end

    def get_mask
      return self
    end

    def get_size target = :all
      target = target.to_sym
      return @size          if (target == :all)
      return @size[target]  if (@size.keys.include?(target))
      return nil
    end

    def get_origin target = :all
      target = target.to_sym
      return @origin          if (target == :all)
      return @origin[target]  if (@origin.keys.include?(target))
      return nil
    end

    def get_corner side_x, side_y
      side_x = side_x.to_sym
      side_y = side_y.to_sym
      return Point.new(
        get_side(side_x),
        get_side(side_y)
      )  unless ([side_x, side_y].include? :center)
      if    (side_x == side_y)
        center = get_center.values
        return Point.new(*center)
      elsif (side_x == :center)
        return Point.new(
          get_center(:x),
          get_side(side_y)
        )
      elsif (side_y == :center)
        return Point.new(
          get_side(side_x),
          get_center(:y)
        )
      end
      return nil
    end

    def get_side side
      side = side.to_sym
      case side
      when :left
        return get_side_left
      when :right
        return get_side_right
      when :top
        return get_side_top
      when :bottom
        return get_side_bottom
      else
        return nil
      end
    end

    def get_sides
      return {
        left:   get_side(:left),
        right:  get_side(:right),
        top:    get_side(:top),
        bottom: get_side(:bottom)
      }
    end

    def get_center target = :all
      target = target.to_sym
      return Point.new(
        get_center_x,
        get_center_y
      )  if (target == :all)
      return method("get_center_#{target.to_s}".to_sym).call  if (get_point.keys.include? target)
    end

    def collides_with? other
      return collides_with_point? other  if (other.is_a?(Point))
      return collides_with_mask?  other  if (other.is_a?(Mask) || other.is_a?(Rectangle))
      return collides_with_hash?  other  if (other.is_a?(Hash))
    end

    def collides_with_point? point
      return (
        point.x >= get_side(:left)  &&
        point.x <  get_side(:right) &&
        point.y >= get_side(:top)   &&
        point.y <  get_side(:bottom)
      )
    end

    def collides_with_mask? mask
      this_sides  = get_sides
      other_sides = mask.get_sides
      return (
        (
          (
            other_sides[:left] >= this_sides[:left] &&
            other_sides[:left] <= this_sides[:right]
          ) || (
            other_sides[:right] >= this_sides[:left] &&
            other_sides[:right] <= this_sides[:right]
          )
        ) && (
          (
            other_sides[:top] >= this_sides[:top]  &&
            other_sides[:top] <= this_sides[:bottom]
          ) || (
            other_sides[:bottom] >= this_sides[:top]  &&
            other_sides[:bottom] <= this_sides[:bottom]
          )
        )
      )
    end

    def collides_with_hash? other_hash
      if (hash.keys.include_all?(:x, :y))
        other_point = Point.new hash[:x], hash[:y]
        return collides_with_point? other_point
      end
      return nil
    end

    private

      def set_position_from position
        if    (position.is_a?(Point))
          position.assign_to self
        elsif (position.is_a?(Hash))
          Point.new(
            position[:x],
            position[:y],
            assign_to: self
          )
        else
          Helpers::Error.error "Cannot set Point as `#{position.to_s}:#{position.class.name}' for Mask."
        end
      end

      def get_side_left
        case get_origin(:x)
        when :left
          return get_position(:x)
        when :right
          return get_position(:x) - get_size(:width)
        when :center
          return get_position(:x) - (get_size(:width) * 0.5)
        else
          return nil
        end
      end

      def get_side_right
        case get_origin(:x)
        when :left
          return get_position(:x) + get_size(:width)
        when :right
          return get_position(:x)
        when :center
          return get_position(:x) + (get_size(:width) * 0.5)
        else
          return nil
        end
      end

      def get_side_top
        case get_origin(:y)
        when :top
          return get_position(:y)
        when :bottom
          return get_position(:y) - get_size(:height)
        when :center
          return get_position(:y) - (get_size(:height) * 0.5)
        else
          return nil
        end
      end

      def get_side_bottom
        case get_origin(:y)
        when :top
          return get_position(:y) + get_size(:height)
        when :bottom
          return get_position(:y)
        when :center
          return get_position(:y) + (get_size(:height) * 0.5)
        else
          return nil
        end
      end

      def get_center_x
        case get_origin(:x)
        when :left
          return get_position(:x) + (get_size(:width) * 0.5)
        when :right
          return get_position(:x) - (get_size(:width) * 0.5)
        when :center
          return get_position(:x)
        end
      end

      def get_center_y
        case get_origin(:y)
        when :top
          return get_position(:y) + (get_size(:height) * 0.5)
        when :bottom
          return get_position(:y) - (get_size(:height) * 0.5)
        when :center
          return get_position(:y)
        end
      end
  end
end
