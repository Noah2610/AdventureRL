module AdventureRL
  class Mask
    DEFAULT_ARGS = {
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
      }
    }

    def initialize args = {}
      options   = DEFAULT_ARGS.merge args
      @position = get_position_from_arg options[:position]
      @size     = options[:size]
      @origin   = options[:origin]
    end

    def get_point
      return @position
    end

    def get_position target = :all
      return get_point.get_position target
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

    def get_center target = :all
      target = target.to_sym
      return Point.new(
        get_center_x,
        get_center_y
      )  if (target == :all)
      return method("get_center_#{target.to_s}".to_sym).call  if (get_point.keys.include? target)
    end

    private

    def get_position_from_arg position_arg
      return position_arg  if (position_arg.is_a? Point)
      return Point.new(
        position_arg[:x],
        position_arg[:y]
      )                    if (position_arg.is_a? Hash)
      return nil
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
